import express from 'express';
import { writeFile } from 'fs/promises';
import {
    randomUUID,
    createHmac,
    timingSafeEqual
} from 'crypto';

const app = express();

const PORT = process.env.PORT || 3000;

const DEPLOY_TOKEN = process.env.DEPLOY_TOKEN;
const GITHUB_WEBHOOK_SECRET = process.env.GITHUB_WEBHOOK_SECRET;

const QUEUE_PATH = '/queue';

/*
|--------------------------------------------------------------------------
| GitHub Webhook
|--------------------------------------------------------------------------
|
| Este endpoint necesita el body original para poder verificar
| X-Hub-Signature-256.
|
*/

app.post(
    '/github-webhook',
    express.raw({ type: 'application/json' }),
    async (req, res) => {
        try {
            const signature = req.headers['x-hub-signature-256'];
            const event = req.headers['x-github-event'];
            const delivery = req.headers['x-github-delivery'];

            /*
            |--------------------------------------------------------------------------
            | 1. Verificar que exista el secret
            |--------------------------------------------------------------------------
            */

            if (!GITHUB_WEBHOOK_SECRET) {
                console.error(
                    'GITHUB_WEBHOOK_SECRET no está configurado'
                );

                return res.status(500).json({
                    success: false,
                    message: 'Webhook secret no configurado'
                });
            }

            /*
            |--------------------------------------------------------------------------
            | 2. Verificar que GitHub haya enviado la firma
            |--------------------------------------------------------------------------
            */

            if (!signature) {
                return res.status(401).json({
                    success: false,
                    message: 'Falta X-Hub-Signature-256'
                });
            }

            /*
            |--------------------------------------------------------------------------
            | 3. Verificar que sea un evento push
            |--------------------------------------------------------------------------
            */

            if (event !== 'push') {
                return res.status(200).json({
                    success: true,
                    message: `Evento ${event} ignorado`
                });
            }

            /*
            |--------------------------------------------------------------------------
            | 4. Verificar formato de la firma
            |--------------------------------------------------------------------------
            */

            if (!signature.startsWith('sha256=')) {
                return res.status(401).json({
                    success: false,
                    message: 'Formato de firma inválido'
                });
            }

            /*
            |--------------------------------------------------------------------------
            | 5. Calcular nuestra propia firma
            |--------------------------------------------------------------------------
            */

            const expectedSignature =
                'sha256=' +
                createHmac(
                    'sha256',
                    GITHUB_WEBHOOK_SECRET
                )
                    .update(req.body)
                    .digest('hex');

            /*
            |--------------------------------------------------------------------------
            | 6. Comparación segura
            |--------------------------------------------------------------------------
            */

            const receivedBuffer = Buffer.from(signature);
            const expectedBuffer = Buffer.from(expectedSignature);

            if (
                receivedBuffer.length !== expectedBuffer.length ||
                !timingSafeEqual(
                    receivedBuffer,
                    expectedBuffer
                )
            ) {
                console.warn(
                    `Firma inválida. Delivery: ${delivery ?? 'desconocido'}`
                );

                return res.status(401).json({
                    success: false,
                    message: 'Firma inválida'
                });
            }

            /*
            |--------------------------------------------------------------------------
            | 7. Parsear el JSON DESPUÉS de verificar la firma
            |--------------------------------------------------------------------------
            */

            const payload = JSON.parse(req.body.toString('utf8'));

            /*
            |--------------------------------------------------------------------------
            | 8. Obtener información del repositorio
            |--------------------------------------------------------------------------
            */

            const repository = payload.repository?.full_name;

            const branch = payload.ref;

            console.log(
                `Webhook GitHub válido: ${repository}`
            );

            console.log(
                `Branch: ${branch}`
            );

            console.log(
                `Delivery: ${delivery ?? 'desconocido'}`
            );

            /*
            |--------------------------------------------------------------------------
            | 9. Solo permitir main
            |--------------------------------------------------------------------------
            */

            if (branch !== 'refs/heads/main') {
                return res.status(200).json({
                    success: true,
                    message: 'Push fuera de main ignorado'
                });
            }

            /*
            |--------------------------------------------------------------------------
            | 10. Determinar proyecto
            |--------------------------------------------------------------------------
            */

            const projects = {
                'MatiasParente/FreezerGuard': 'FreezerGuard'
            };

            const project = projects[repository];

            if (!project) {
                console.warn(
                    `Repositorio no registrado: ${repository}`
                );

                return res.status(403).json({
                    success: false,
                    message: 'Repositorio no autorizado'
                });
            }

            /*
            |--------------------------------------------------------------------------
            | 11. Crear orden de deploy
            |--------------------------------------------------------------------------
            */

            const id = randomUUID();

            const request = {
                id,
                project,
                repository,
                branch: 'main',
                delivery,
                commit: payload.after,
                created_at: new Date().toISOString()
            };

            await writeFile(
                `${QUEUE_PATH}/${id}.json`,
                JSON.stringify(request, null, 2)
            );

            console.log(
                `Deploy solicitado: ${project} (${id})`
            );

            /*
            |--------------------------------------------------------------------------
            | 12. Responder a GitHub
            |--------------------------------------------------------------------------
            */

            return res.status(202).json({
                success: true,
                message: `Deploy de ${project} encolado`,
                id
            });

        } catch (error) {
            console.error(
                'Error procesando webhook:',
                error
            );

            return res.status(500).json({
                success: false,
                message: 'Error procesando webhook'
            });
        }
    }
);

/*
|--------------------------------------------------------------------------
| JSON normal
|--------------------------------------------------------------------------
*/

app.use(express.json());

/*
|--------------------------------------------------------------------------
| Health check
|--------------------------------------------------------------------------
*/

app.get('/health', (req, res) => {
    res.json({
        success: true,
        service: 'deploy-service'
    });
});

/*
|--------------------------------------------------------------------------
| Deploy manual / n8n
|--------------------------------------------------------------------------
*/

app.post('/deploy', async (req, res) => {
    try {
        const token = req.headers['x-deploy-token'];

        if (!DEPLOY_TOKEN || token !== DEPLOY_TOKEN) {
            return res.status(401).json({
                success: false,
                message: 'Unauthorized'
            });
        }

        const { project } = req.body;

        if (!project) {
            return res.status(400).json({
                success: false,
                message: 'Proyecto requerido'
            });
        }

        const id = randomUUID();

        const request = {
            id,
            project,
            source: 'manual',
            created_at: new Date().toISOString()
        };

        await writeFile(
            `${QUEUE_PATH}/${id}.json`,
            JSON.stringify(request, null, 2)
        );

        console.log(
            `Deploy manual solicitado: ${project} (${id})`
        );

        return res.status(202).json({
            success: true,
            message: `Deploy de ${project} encolado`,
            id
        });

    } catch (error) {
        console.error(error);

        return res.status(500).json({
            success: false,
            message: 'No se pudo crear la orden de deploy'
        });
    }
});

/*
|--------------------------------------------------------------------------
| Server
|--------------------------------------------------------------------------
*/

app.listen(PORT, '0.0.0.0', () => {
    console.log(
        `Deploy service escuchando en puerto ${PORT}`
    );
});
import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import helmet from 'helmet';
import compression from 'compression';
import { Request, Response, NextFunction } from 'express';

async function bootstrap() {
  const app = await NestFactory.create(AppModule, { cors: false });

  app.use(helmet());
  app.use(compression());

  // API bajo /api
  app.setGlobalPrefix('api');

  const env = process.env.NODE_ENV || 'development';
  const allowedOrigin = process.env.ALLOWED_ORIGIN || (env === 'production'
    ? 'https://your-frontend.up.railway.app'
    : 'http://localhost:8080');

  app.enableCors({
    origin: [allowedOrigin],
    credentials: true,
    methods: ['GET','POST','PUT','PATCH','DELETE','OPTIONS'],
    allowedHeaders: ['Content-Type','Authorization','x-frontend-key'],
  });

  // En prod, exigir header compartido desde el proxy del frontend
  const sharedKey = process.env.FRONTEND_SHARED_KEY;
  if (env === 'production' && sharedKey) {
    app.use((req: Request, res: Response, next: NextFunction) => {
      if (req.path === '/api/health') return next(); // health abierto
      const got = req.header('x-frontend-key');
      if (got !== sharedKey) return res.status(403).json({ error: 'Forbidden' });
      return next();
    });
  }

  const port = parseInt(process.env.PORT ?? '3000', 10);
  app.setGlobalPrefix('api');
  await app.listen(port, '0.0.0.0');
  console.log(`API listening on :${port} (NODE_ENV=${env}) allowedOrigin=${allowedOrigin}`);
}
bootstrap();

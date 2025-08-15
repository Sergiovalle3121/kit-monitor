import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import helmet from 'helmet';
import compression from 'compression';

async function bootstrap() {
  const app = await NestFactory.create(AppModule, { cors: false });

  app.use(helmet());
  app.use(compression());

  const allowedOrigin =
    process.env.NODE_ENV === 'production'
      ? 'https://mindful-presence-production-1bd7.up.railway.app'
      : 'http://localhost:8080';

  app.enableCors({
    origin: [allowedOrigin],
    credentials: true,
    methods: ['GET','POST','PUT','PATCH','DELETE','OPTIONS'],
    allowedHeaders: ['Content-Type','Authorization'],
  });

  const port = parseInt(process.env.PORT ?? '3000', 10);
  await app.listen(port, '0.0.0.0');
  console.log(`API listening on :${port} (NODE_ENV=${process.env.NODE_ENV})`);
}
bootstrap();

import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  const port = parseInt(process.env.PORT ?? '3000', 10);
  const url = process.env.DATABASE_URL;

  if (!url) throw new Error('DATABASE_URL is not set');

  try {
    const u = new URL(url);
    console.log(`[DB] host=${u.hostname} db=${u.pathname.slice(1)}`);
  } catch {
    console.warn('[DB] DATABASE_URL invalid format');
  }

  await app.listen(port, '0.0.0.0');
  console.log(`[HTTP] listening on 0.0.0.0:${port}`);
}
bootstrap();
// Cambio mínimo para forzar redeploy
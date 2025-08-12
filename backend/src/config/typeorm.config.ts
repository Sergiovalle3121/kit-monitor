import { ConfigService } from '@nestjs/config';
import { TypeOrmModuleOptions } from '@nestjs/typeorm';

export default function typeormFactory(config: ConfigService): TypeOrmModuleOptions {
  const url = process.env.DATABASE_URL || config.get<string>('DATABASE_URL');
  if (!url) {
    throw new Error('DATABASE_URL is not set.');
  }
  try {
    const u = new URL(url);
    console.log(`[DB] host=${u.hostname} db=${u.pathname.slice(1)}`);
  } catch {}
  return {
    type: 'postgres',
    url,
    autoLoadEntities: true,
    synchronize: false,
    ssl: process.env.NODE_ENV === 'production' ? { rejectUnauthorized: false } : false,
  };
}

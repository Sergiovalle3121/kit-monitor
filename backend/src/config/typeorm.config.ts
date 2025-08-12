import { ConfigService } from '@nestjs/config';
import { TypeOrmModuleOptions } from '@nestjs/typeorm';

export default function typeormFactory(config: ConfigService): TypeOrmModuleOptions {
  const url = process.env.DATABASE_URL || config.get<string>('DATABASE_URL');

  if (!url) {
    // Falla temprano y con mensaje claro en Railway
    throw new Error('DATABASE_URL is not set. Define it in Railway → Variables.');
  }

  return {
    type: 'postgres',
    url,
    autoLoadEntities: true,
    synchronize: false, // true solo en dev
    ssl: process.env.NODE_ENV === 'production' ? { rejectUnauthorized: false } : false,
    // logging: true, // opcional
  };
}

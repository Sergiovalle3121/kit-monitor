import { ConfigService } from '@nestjs/config';
import { TypeOrmModuleOptions } from '@nestjs/typeorm';

export default function typeormFactory(config: ConfigService): TypeOrmModuleOptions {
  let url = process.env.DATABASE_URL || config.get<string>('DATABASE_URL');
  if (!url) throw new Error('DATABASE_URL is not set.');

  // Garantiza sslmode en la URL
  if (!/[?&]sslmode=/.test(url)) {
    url += (url.includes('?') ? '&' : '?') + 'sslmode=require';
  }

  return {
    type: 'postgres',
    url,
    autoLoadEntities: true,
    synchronize: false,
    // Fuerza SSL "no-verify" para certificados self-signed
    ssl: { rejectUnauthorized: false },
    extra: { ssl: { rejectUnauthorized: false } },
  };
}


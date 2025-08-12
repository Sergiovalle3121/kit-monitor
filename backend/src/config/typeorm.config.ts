import { ConfigService } from '@nestjs/config';
import { TypeOrmModuleOptions } from '@nestjs/typeorm';

export default function typeormFactory(config: ConfigService): TypeOrmModuleOptions {
  let url = process.env.DATABASE_URL || config.get<string>('DATABASE_URL');
  if (!url) throw new Error('DATABASE_URL is not set.');

  try {
    const u = new URL(url);
    u.searchParams.delete('sslmode');
    url = u.toString();
  } catch {}

  return {
    type: 'postgres',
    url,
    autoLoadEntities: true,
    synchronize: false,
    ssl: false,
    extra: { ssl: false },
  };
}


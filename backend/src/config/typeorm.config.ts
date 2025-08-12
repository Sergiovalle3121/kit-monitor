import { TypeOrmModuleOptions } from '@nestjs/typeorm';
import { ConfigService } from '@nestjs/config';

export default (configService: ConfigService): TypeOrmModuleOptions => {
  const isProd = configService.get<string>('NODE_ENV') === 'production';

  // Si está definida, usamos DATABASE_URL; si no, usamos los DB_* por separado
  const databaseUrl = configService.get<string>('DATABASE_URL');

  const common = {
    type: 'postgres' as const,
    autoLoadEntities: true,
    synchronize: configService.get<boolean>('DB_SYNC', false), // en prod: false
    logging: configService.get<boolean>('DB_LOGGING', false),
    ssl: isProd ? { rejectUnauthorized: false } : false,
  };

  if (databaseUrl) {
    return {
      ...common,
      url: databaseUrl, // <-- Solo incluimos url si existe; si no, ni la mandamos
    };
  }

  return {
    ...common,
    host: configService.get<string>('DB_HOST', 'localhost'),
    port: Number(configService.get<string>('DB_PORT', '5432')),
    username: configService.get<string>('DB_USERNAME', 'postgres'),
    password: configService.get<string>('DB_PASSWORD', 'postgres'),
    database: configService.get<string>('DB_DATABASE', 'kitmonitor'),
  };
};


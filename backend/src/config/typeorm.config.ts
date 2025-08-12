import { TypeOrmModuleOptions } from '@nestjs/typeorm';
import { ConfigService } from '@nestjs/config';

export default (configService: ConfigService): TypeOrmModuleOptions => {
  const url = configService.get<string>('DATABASE_URL');

  if (url) {
    return {
      type: 'postgres',
      url,
      ssl: { rejectUnauthorized: false }, // necesario en Railway
      entities: [__dirname + '/../**/*.entity{.ts,.js}'],
      synchronize: configService.get<boolean>('DB_SYNC', false),
      logging: configService.get<boolean>('DB_LOGGING', false),
    };
  }

  // Fallback para local (.env)
  return {
    type: 'postgres',
    host: configService.get<string>('DB_HOST', 'localhost'),
    port: Number(configService.get<string>('DB_PORT', '5432')),
    username: configService.get<string>('DB_USERNAME', 'postgres'),
    password: configService.get<string>('DB_PASSWORD', 'postgres'),
    database: configService.get<string>('DB_DATABASE', 'kitmonitor'),
    entities: [__dirname + '/../**/*.entity{.ts,.js}'],
    synchronize: configService.get<boolean>('DB_SYNC', true),
    logging: configService.get<boolean>('DB_LOGGING', false),
  };
};

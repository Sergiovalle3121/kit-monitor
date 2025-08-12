import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';

import typeormFactory from './config/typeorm.config';

import { AuthModule } from './modules/auth/auth.module';
import { UsersModule } from './modules/users/users.module';
import { ModelsModule } from './modules/models/models.module';
import { KitsModule } from './modules/kits/kits.module';
import { ReportsModule } from './modules/reports/reports.module';

@Module({
  imports: [
    // Carga variables de entorno (global). En producción tomará process.env (Railway).
    // Si quieres usar archivo local en dev, puedes crear .env y se cargará automáticamente.
    ConfigModule.forRoot({
      isGlobal: true,
    }),

    // TypeORM con factory que lee DATABASE_URL (y hace fallback si lo programaste)
    TypeOrmModule.forRootAsync({
      imports: [ConfigModule],
      inject: [ConfigService],
      useFactory: typeormFactory, // <-- tu ./config/typeorm.config export default
    }),

    // Módulos de la app
    AuthModule,
    UsersModule,
    ModelsModule,
    KitsModule,
    ReportsModule,
  ],
})
export class AppModule {}

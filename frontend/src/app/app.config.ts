// frontend/src/app/app.config.ts
import { ApplicationConfig } from '@angular/core';
import { provideRouter } from '@angular/router';
import { routes } from './app.routes';

import { provideHttpClient, withInterceptors } from '@angular/common/http';
import { jwtInterceptor } from './core/jwt-interceptor';

import { provideAnimations } from '@angular/platform-browser/animations'; // <- necesario para Angular Material

export const appConfig: ApplicationConfig = {
  providers: [
    provideRouter(routes),
    provideHttpClient(withInterceptors([jwtInterceptor])), // <- HttpClient para tus servicios
    provideAnimations(),                                    // <- Animations para Material
  ],
};

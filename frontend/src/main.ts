import { bootstrapApplication } from '@angular/platform-browser';
import { provideRouter, Routes } from '@angular/router';
import { provideHttpClient, withInterceptors } from '@angular/common/http';
import { AppComponent } from './app/app.component';
import { LoginComponent } from './app/pages/login/login';
import { DashboardComponent } from './app/pages/dashboard/dashboard';
import { KitsComponent } from './app/pages/kits/kits';
import { ModelsComponent } from './app/pages/models/models';
import { ReportsComponent } from './app/pages/reports/reports';
import { ShellComponent } from './app/layout/shell/shell';
import { jwtInterceptor } from './app/core/jwt-interceptor';
// Si usas el guard funcional, impórtalo y aplícalo en las rutas protegidas.
// import { authGuard } from './app/core/auth.guard';

const routes: Routes = [
  { path: 'login', component: LoginComponent },
  {
    path: '',
    component: ShellComponent,
    // canActivate: [authGuard], // habilítalo cuando el guard esté operativo
    children: [
      { path: 'dashboard', component: DashboardComponent },
      { path: 'kits', component: KitsComponent },
      { path: 'models', component: ModelsComponent },
      { path: 'reports', component: ReportsComponent },
      { path: '', pathMatch: 'full', redirectTo: 'dashboard' },
    ],
  },
  { path: '**', redirectTo: '' },
];

bootstrapApplication(AppComponent, {
  providers: [
    provideRouter(routes),
    provideHttpClient(withInterceptors([jwtInterceptor])),
  ],
}).catch((err) => console.error(err));

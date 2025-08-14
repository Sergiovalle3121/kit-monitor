import { Routes } from '@angular/router';
import { DashboardComponent } from './pages/dashboard/dashboard'; // <-- Update this path if the file is located elsewhere, e.g. './pages/Dashboard/dashboard.component' or './dashboard/dashboard.component'

export const routes: Routes = [
  { path: '', component: DashboardComponent },
  // otras rutas...
];

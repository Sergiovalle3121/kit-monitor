import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { HttpClient } from '@angular/common/http';
import { MatCardModule } from '@angular/material/card';
import { MatTableModule } from '@angular/material/table';
import { MatButtonModule } from '@angular/material/button';
import { environment } from '../../../environments/environment';

type Row = { id: number; nombre: string; estado: 'OK' | 'WARN' | 'ERROR' };

@Component({
  selector: 'app-dashboard',
  standalone: true,
  imports: [CommonModule, MatCardModule, MatTableModule, MatButtonModule],
  templateUrl: './dashboard.component.html',
  styleUrls: ['./dashboard.component.css']
})
export class DashboardComponent implements OnInit {
  apiStatus: 'loading' | 'ok' | 'fail' = 'loading';
  apiMessage = '';
  // Tarjetas
  cards = [
    { title: 'Kits', value: 12 },
    { title: 'Alertas', value: 3 },
    { title: 'Usuarios', value: 5 },
  ];

  // Gráfico (valores dummy, puedes remplazar por datos reales)
  chartData = [5, 9, 2, 7, 3, 10, 6];
  selectedBar = -1;

  // Tabla
  displayedColumns = ['id', 'nombre', 'estado', 'acciones'];
  data: Row[] = [
    { id: 1, nombre: 'Kit A', estado: 'OK' },
    { id: 2, nombre: 'Kit B', estado: 'WARN' },
    { id: 3, nombre: 'Kit C', estado: 'ERROR' },
  ];

  constructor(private http: HttpClient) {}

  ngOnInit() { this.checkApi(); }

  checkApi() {
    this.apiStatus = 'loading';
    this.http.get(`${environment.apiUrl}/health`, { responseType: 'text' })
      .subscribe({
        next: (msg) => { this.apiStatus = 'ok'; this.apiMessage = String(msg); },
        error: (err) => { this.apiStatus = 'fail'; this.apiMessage = err?.message ?? 'Error'; }
      });
  }

  randomize() {
    this.chartData = this.chartData.map(() => Math.floor(Math.random() * 10) + 1);
    this.cards = this.cards.map(c => ({ ...c, value: Math.floor(Math.random() * 20) }));
  }

  onRowClick(r: Row) { alert(`Abrir detalle del ${r.nombre} (id ${r.id})`); }
  onBarClick(i: number) { this.selectedBar = i; }
}

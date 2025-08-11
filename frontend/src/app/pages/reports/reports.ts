import { Component, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ApiService } from '../../core/api.service';

type Report = { id: number; title: string; };

@Component({
  selector: 'app-reports',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './reports.html',
  styleUrls: ['./reports.css']
})
export class ReportsComponent {
  reports: Report[] = [];
  private api = inject(ApiService);

  ngOnInit() {
    this.api.get<Report[]>('/reports').subscribe((res: Report[]) => (this.reports = res));
  }
}

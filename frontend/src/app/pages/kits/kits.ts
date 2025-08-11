import { Component, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ApiService } from '../../core/api.service';

type Kit = { id: number; name: string; };

@Component({
  selector: 'app-kits',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './kits.html',
  styleUrls: ['./kits.css']
})
export class KitsComponent {
  kits: Kit[] = [];
  private api = inject(ApiService);

  ngOnInit() {
    this.api.get<Kit[]>('/kits').subscribe((res: Kit[]) => (this.kits = res));
  }
}

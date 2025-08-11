import { Injectable } from '@angular/core';
import { ApiService } from './api.service';
import { tap, map } from 'rxjs/operators';
import { Observable } from 'rxjs';

@Injectable({ providedIn: 'root' })
export class AuthService {
  private tokenKey = 'access_token';
  constructor(private api: ApiService) {}

  login(email: string, password: string): Observable<void> {
    return this.api.post<{ access_token: string }>('/auth/login', { email, password })
      .pipe(tap(res => localStorage.setItem(this.tokenKey, res.access_token)), map(() => void 0));
  }
  logout() { localStorage.removeItem(this.tokenKey); }
  getToken() { return localStorage.getItem(this.tokenKey); }
  isLoggedIn() { return !!this.getToken(); }
}

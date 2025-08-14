import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders, HttpParams } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../environments/environment';

@Injectable({ providedIn: 'root' })
export class ApiService {
  private readonly base = environment.apiUrl; // https://kit-monitor-production.up.railway.app

  constructor(private http: HttpClient) {}

  get<T>(path: string, params?: HttpParams, headers?: HttpHeaders): Observable<T> {
    return this.http.get<T>(`${this.base}${path}`, { params, headers });
  }

  post<T>(path: string, body?: unknown, headers?: HttpHeaders): Observable<T> {
    return this.http.post<T>(`${this.base}${path}`, body, { headers });
  }

  put<T>(path: string, body?: unknown, headers?: HttpHeaders): Observable<T> {
    return this.http.put<T>(`${this.base}${path}`, body, { headers });
  }

  delete<T>(path: string, params?: HttpParams, headers?: HttpHeaders): Observable<T> {
    return this.http.delete<T>(`${this.base}${path}`, { params, headers });
  }
}

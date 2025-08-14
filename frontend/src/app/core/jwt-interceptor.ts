import { HttpInterceptorFn } from '@angular/common/http';
import { environment } from '../../environments/environment';

export const jwtInterceptor: HttpInterceptorFn = (req, next) => {
  const token = localStorage.getItem('token') || sessionStorage.getItem('token');

  const absoluteUrl = req.url.startsWith('http')
    ? req.url
    : `${environment.apiUrl}${req.url.startsWith('/') ? '' : '/'}${req.url}`;

  const authReq = token
    ? req.clone({ url: absoluteUrl, setHeaders: { Authorization: `Bearer ${token}` } })
    : req.clone({ url: absoluteUrl });

  return next(authReq);
}
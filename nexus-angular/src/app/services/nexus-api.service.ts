import { HttpClient, HttpParams } from '@angular/common/http';
import { Injectable, inject } from '@angular/core';
import { Observable } from 'rxjs';
import { environment } from '../../environments/environment';
import { Category, Config, DropdownListItem, Section } from '../models/nexus.models';

/**
 * Thin client over the Nexus REST API (Keryhe.Nexus.Api). One method per endpoint.
 */
@Injectable({ providedIn: 'root' })
export class NexusApiService {
  private readonly http = inject(HttpClient);
  private readonly base = environment.apiBase;

  getCategories(): Observable<Category[]> {
    return this.http.get<Category[]>(`${this.base}/categories`);
  }

  getSections(categoryId: number): Observable<Section[]> {
    return this.http.get<Section[]>(`${this.base}/categories/${categoryId}/sections`);
  }

  getConfigs(sectionIds: number[]): Observable<Config[]> {
    let params = new HttpParams();
    for (const id of sectionIds) {
      params = params.append('sectionId', id);
    }
    return this.http.get<Config[]>(`${this.base}/configs`, { params });
  }

  getDropdownItems(dropdownListId: number): Observable<DropdownListItem[]> {
    return this.http.get<DropdownListItem[]>(`${this.base}/dropdown-lists/${dropdownListId}/items`);
  }

  updateConfigValue(id: number, value: string | null, isEncrypted: boolean): Observable<void> {
    return this.http.put<void>(`${this.base}/configs/${id}/value`, { value, isEncrypted });
  }
}

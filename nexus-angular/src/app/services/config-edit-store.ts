import { Injectable, computed, signal } from '@angular/core';
import { Observable, forkJoin, map, of } from 'rxjs';
import { Config } from '../models/nexus.models';
import { NexusApiService } from './nexus-api.service';

interface EditEntry {
  config: Config;
  value: string | null;
  isEncrypted: boolean;
}

/**
 * Holds pending (unsaved) config edits for the current category so the deeply-nested
 * editors and the category-level Save/Cancel bar can share state. Provided per
 * NexusPanelComponent instance.
 */
@Injectable()
export class ConfigEditStore {
  private readonly edits = signal(new Map<number, EditEntry>());

  /** Bumped on save/cancel/reset so editors re-seed from their (now-current) Config. */
  readonly resetTick = signal(0);

  readonly dirtyCount = computed(() => this.edits().size);
  readonly hasChanges = computed(() => this.edits().size > 0);

  /** Records an edit when it differs from the persisted Config, otherwise clears it. */
  setEdit(config: Config, value: string | null, isEncrypted: boolean): void {
    const isDirty = value !== config.value || isEncrypted !== config.isEncrypted;
    const next = new Map(this.edits());
    if (isDirty) {
      next.set(config.id, { config, value, isEncrypted });
    } else {
      next.delete(config.id);
    }
    this.edits.set(next);
  }

  clearEdit(id: number): void {
    if (!this.edits().has(id)) return;
    const next = new Map(this.edits());
    next.delete(id);
    this.edits.set(next);
  }

  /** Persists every pending edit (one PUT each), applies values back to the Config, then resets. */
  saveAll(api: NexusApiService): Observable<number> {
    const entries = [...this.edits().values()];
    if (entries.length === 0) return of(0);

    return forkJoin(
      entries.map((e) =>
        api.updateConfigValue(e.config.id, e.value, e.isEncrypted).pipe(
          map(() => {
            e.config.value = e.value;
            e.config.isEncrypted = e.isEncrypted;
          }),
        ),
      ),
    ).pipe(
      map(() => {
        this.reset();
        return entries.length;
      }),
    );
  }

  /** Discards all pending edits; editors re-seed from the unchanged Config. */
  cancelAll(): void {
    this.reset();
  }

  /** Clears all pending edits and signals editors to re-seed. */
  reset(): void {
    if (this.edits().size > 0) this.edits.set(new Map());
    this.resetTick.update((n) => n + 1);
  }
}

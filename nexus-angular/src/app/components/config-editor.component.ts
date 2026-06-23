import { Component, Input, OnChanges, effect, inject, untracked } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { MatButtonModule } from '@angular/material/button';
import { MatNativeDateModule } from '@angular/material/core';
import { MatDatepickerModule } from '@angular/material/datepicker';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatIconModule } from '@angular/material/icon';
import { MatInputModule } from '@angular/material/input';
import { MatSelectModule } from '@angular/material/select';
import { MatSlideToggleModule } from '@angular/material/slide-toggle';
import { MatSnackBar } from '@angular/material/snack-bar';
import { MatTooltipModule } from '@angular/material/tooltip';
import { Config, DropdownListItem } from '../models/nexus.models';
import { ConfigEditStore } from '../services/config-edit-store';
import { NexusApiService } from '../services/nexus-api.service';

const STRING_DATA_TYPES = new Set(['json', 'guid', 'url', 'email', 'multiline', 'string']);

/**
 * Editable row for a single Config value. Picks a control from `dataType`. Edits are
 * deferred: changes are reported to the ConfigEditStore (not saved immediately) and
 * committed/reverted by the category-level Save/Cancel bar.
 */
@Component({
  selector: 'nexus-config-editor',
  standalone: true,
  imports: [
    FormsModule,
    MatFormFieldModule,
    MatInputModule,
    MatSelectModule,
    MatSlideToggleModule,
    MatDatepickerModule,
    MatNativeDateModule,
    MatIconModule,
    MatButtonModule,
    MatTooltipModule,
  ],
  templateUrl: './config-editor.component.html',
  styleUrl: './config-editor.component.scss',
})
export class ConfigEditorComponent implements OnChanges {
  @Input({ required: true }) config!: Config;

  private readonly api = inject(NexusApiService);
  private readonly snack = inject(MatSnackBar);
  private readonly store = inject(ConfigEditStore);

  // Canonical string of the pending edit; also backs all text-like controls.
  editValue: string | null = null;
  // Pending encrypted flag (not applied to `config` until saved).
  editIsEncrypted = false;

  // Typed backing fields for non-string controls.
  boolValue = false;
  numberValue: number | null = null;
  dateValue: Date | null = null;
  timeValue: string | null = null;       // HH:mm[:ss]
  datetimeValue: string | null = null;    // yyyy-MM-ddTHH:mm (datetime-local)
  colorValue = '#000000';

  dropdownItems: DropdownListItem[] = [];
  private dropdownItemsLoaded = false;

  constructor() {
    // Re-seed from the (now-current) Config whenever the store is saved/cancelled.
    // Only resetTick is a reactive dependency; the re-seed runs untracked so reading/
    // writing the edits signal inside initializeValues doesn't re-trigger this effect.
    effect(() => {
      this.store.resetTick();
      untracked(() => {
        if (this.config) this.initializeValues();
      });
    });
  }

  /** True when the pending edit differs from the persisted Config. */
  get isDirty(): boolean {
    return this.editValue !== this.config.value || this.editIsEncrypted !== this.config.isEncrypted;
  }

  get type(): string {
    return (this.config.dataType ?? '').toLowerCase();
  }

  get isStringType(): boolean {
    return STRING_DATA_TYPES.has(this.type);
  }

  get textInputType(): string {
    if (this.editIsEncrypted) return 'password';
    if (this.type === 'url') return 'url';
    if (this.type === 'email') return 'email';
    return 'text';
  }

  ngOnChanges(): void {
    this.initializeValues();
  }

  private initializeValues(): void {
    const raw = this.config.value;
    this.editValue = raw;
    this.editIsEncrypted = this.config.isEncrypted;
    this.dropdownItemsLoaded = false;
    // Starting from the persisted value means no pending edit for this config.
    this.store.clearEdit(this.config.id);

    // Load dropdown options up front so the selected value renders immediately
    // (mat-select needs the matching option present to show its label).
    if (this.type === 'dropdown') this.ensureDropdownItems();

    switch (this.type) {
      case 'bool':
        this.boolValue = raw?.toLowerCase() === 'true';
        break;
      case 'int':
      case 'float':
        this.numberValue = raw != null && raw !== '' && !isNaN(Number(raw)) ? Number(raw) : null;
        break;
      case 'date': {
        const d = raw ? new Date(raw) : null;
        this.dateValue = d && !isNaN(d.getTime()) ? d : null;
        break;
      }
      case 'time':
        this.timeValue = raw ?? null;
        break;
      case 'datetime': {
        const d = raw ? new Date(raw) : null;
        this.datetimeValue = d && !isNaN(d.getTime()) ? this.toLocalInput(d) : null;
        break;
      }
      case 'color':
        this.colorValue = raw && raw.trim() !== '' ? raw : '#000000';
        break;
    }
  }

  // ── change/blur handlers (report pending edits; no immediate save) ──────

  onTextSave(): void {
    this.report();
  }

  onBoolChange(): void {
    this.editValue = this.boolValue ? 'true' : 'false';
    this.report();
  }

  onNumberSave(): void {
    this.editValue = this.numberValue != null ? String(this.numberValue) : null;
    this.report();
  }

  onDateChange(): void {
    this.editValue = this.dateValue ? this.formatDate(this.dateValue) : null;
    this.report();
  }

  onTimeChange(): void {
    this.editValue = this.timeValue && this.timeValue !== '' ? this.timeValue : null;
    this.report();
  }

  onDatetimeChange(): void {
    if (!this.datetimeValue) {
      this.editValue = null;
    } else {
      const d = new Date(this.datetimeValue);
      this.editValue = isNaN(d.getTime()) ? null : d.toISOString();
    }
    this.report();
  }

  onColorChange(): void {
    this.editValue = this.colorValue;
    this.report();
  }

  onDropdownChange(): void {
    this.report();
  }

  onDropdownOpened(opened: boolean): void {
    if (opened) this.ensureDropdownItems();
  }

  toggleEncrypted(): void {
    this.editIsEncrypted = !this.editIsEncrypted;
    this.report();
  }

  private ensureDropdownItems(): void {
    if (this.dropdownItemsLoaded || this.config.dropdownListId == null) return;
    this.api.getDropdownItems(this.config.dropdownListId).subscribe({
      next: (items) => {
        this.dropdownItems = items;
        this.dropdownItemsLoaded = true;
      },
      error: (e) => this.snack.open(`Failed to load options: ${e.message}`, 'Dismiss', { duration: 5000 }),
    });
  }

  /** Push the current pending value to the shared store (committed later by Save). */
  private report(): void {
    this.store.setEdit(this.config, this.editValue, this.editIsEncrypted);
  }

  // ── helpers ────────────────────────────────────────────────────────────

  private formatDate(d: Date): string {
    const y = d.getFullYear();
    const m = String(d.getMonth() + 1).padStart(2, '0');
    const day = String(d.getDate()).padStart(2, '0');
    return `${y}-${m}-${day}`;
  }

  private toLocalInput(d: Date): string {
    const y = d.getFullYear();
    const m = String(d.getMonth() + 1).padStart(2, '0');
    const day = String(d.getDate()).padStart(2, '0');
    const hh = String(d.getHours()).padStart(2, '0');
    const mm = String(d.getMinutes()).padStart(2, '0');
    return `${y}-${m}-${day}T${hh}:${mm}`;
  }
}

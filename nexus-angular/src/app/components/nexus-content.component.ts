import { Component, Input, OnChanges, inject } from '@angular/core';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { MatSnackBar } from '@angular/material/snack-bar';
import { Category, Config, Section } from '../models/nexus.models';
import { ConfigEditStore } from '../services/config-edit-store';
import { NexusApiService } from '../services/nexus-api.service';
import { SectionRendererComponent } from './section-renderer.component';

/**
 * Loads and displays the sections + config values for the selected category, and hosts
 * the category-level Save/Cancel bar for pending edits (ConfigEditStore).
 */
@Component({
  selector: 'nexus-content',
  standalone: true,
  imports: [MatProgressSpinnerModule, MatButtonModule, MatIconModule, SectionRendererComponent],
  templateUrl: './nexus-content.component.html',
  styleUrl: './nexus-content.component.scss',
})
export class NexusContentComponent implements OnChanges {
  @Input() category: Category | null = null;

  private readonly api = inject(NexusApiService);
  private readonly snack = inject(MatSnackBar);
  protected readonly store = inject(ConfigEditStore);

  sections: Section[] = [];
  configs: Config[] = [];
  loading = false;
  saving = false;

  private previousCategoryId: number | null = null;
  private loadGeneration = 0;

  ngOnChanges(): void {
    if (!this.category || this.category.id === this.previousCategoryId) return;

    this.previousCategoryId = this.category.id;
    const categoryId = this.category.id;
    this.loading = true;
    this.store.reset();
    const generation = ++this.loadGeneration;

    this.api.getSections(categoryId).subscribe((sections) => {
      if (generation !== this.loadGeneration) return;
      this.sections = sections;

      const sectionIds = sections.map((s) => s.id);
      if (sectionIds.length === 0) {
        this.configs = [];
        this.loading = false;
        return;
      }

      this.api.getConfigs(sectionIds).subscribe((configs) => {
        if (generation !== this.loadGeneration) return;
        this.configs = configs;
        this.loading = false;
      });
    });
  }

  save(): void {
    this.saving = true;
    this.store.saveAll(this.api).subscribe({
      next: (count) => {
        this.saving = false;
        this.snack.open(`Saved ${count} change${count === 1 ? '' : 's'}.`, undefined, { duration: 3000 });
      },
      error: (e) => {
        this.saving = false;
        this.snack.open(`Failed to save changes: ${e.message}`, 'Dismiss', { duration: 6000 });
      },
    });
  }

  cancel(): void {
    this.store.cancelAll();
  }
}

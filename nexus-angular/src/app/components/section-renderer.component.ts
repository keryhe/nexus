import { Component, Input } from '@angular/core';
import { MatCardModule } from '@angular/material/card';
import { MatExpansionModule } from '@angular/material/expansion';
import { MatListModule } from '@angular/material/list';
import { MatTabsModule } from '@angular/material/tabs';
import { Config, Section } from '../models/nexus.models';
import { ConfigEditorComponent } from './config-editor.component';

/**
 * Renders the child sections of a parent using the parent's SectionType to decide layout,
 * recursing so each section's own children render per that section's SectionType.
 */
@Component({
  selector: 'nexus-section-renderer',
  standalone: true,
  imports: [
    MatTabsModule,
    MatExpansionModule,
    MatCardModule,
    MatListModule,
    ConfigEditorComponent,
  ],
  templateUrl: './section-renderer.component.html',
  styleUrl: './section-renderer.component.scss',
})
export class SectionRendererComponent {
  @Input({ required: true }) sections: Section[] = [];
  @Input({ required: true }) configs: Config[] = [];
  @Input({ required: true }) parentSectionType = 'card';
  /** Null means top-level (direct children of the category). */
  @Input() parentSectionId: number | null = null;

  selectedListIndex = 0;

  get layout(): 'tab-h' | 'tab-v' | 'accordion' | 'card' {
    switch ((this.parentSectionType ?? '').toLowerCase()) {
      case 'tab-h': return 'tab-h';
      case 'tab-v': return 'tab-v';
      case 'accordion': return 'accordion';
      default: return 'card';
    }
  }

  get visibleSections(): Section[] {
    return this.sections
      .filter((s) => s.parentId === this.parentSectionId)
      .sort(this.bySortOrder);
  }

  get directConfigs(): Config[] {
    if (this.parentSectionId == null) return [];
    return this.configs
      .filter((c) => c.sectionId === this.parentSectionId)
      .sort(this.bySortOrder);
  }

  private bySortOrder = (a: { sortOrder: number; displayName: string }, b: { sortOrder: number; displayName: string }) =>
    a.sortOrder - b.sortOrder || a.displayName.localeCompare(b.displayName);
}

import { Component, OnInit, inject } from '@angular/core';
import { MatButtonModule } from '@angular/material/button';
import { MatDialog } from '@angular/material/dialog';
import { MatIconModule } from '@angular/material/icon';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { MatSidenavModule } from '@angular/material/sidenav';
import { MatToolbarModule } from '@angular/material/toolbar';
import { Category } from '../models/nexus.models';
import { ConfigEditStore } from '../services/config-edit-store';
import { NexusApiService } from '../services/nexus-api.service';
import { ThemeService } from '../services/theme.service';
import { ConfirmDialogComponent, ConfirmDialogData } from './confirm-dialog.component';
import { NexusContentComponent } from './nexus-content.component';
import { NexusSidebarComponent } from './nexus-sidebar.component';

/**
 * Standard Material app shell: toolbar + collapsible sidenav drawer (category tree) + content.
 * Owns the per-category ConfigEditStore and guards against losing unsaved edits on navigation.
 */
@Component({
  selector: 'nexus-panel',
  standalone: true,
  imports: [
    MatToolbarModule,
    MatSidenavModule,
    MatButtonModule,
    MatIconModule,
    MatProgressSpinnerModule,
    NexusSidebarComponent,
    NexusContentComponent,
  ],
  providers: [ConfigEditStore],
  templateUrl: './nexus-panel.component.html',
  styleUrl: './nexus-panel.component.scss',
})
export class NexusPanelComponent implements OnInit {
  private readonly api = inject(NexusApiService);
  private readonly store = inject(ConfigEditStore);
  private readonly dialog = inject(MatDialog);
  protected readonly theme = inject(ThemeService);

  categories: Category[] = [];
  selectedCategory: Category | null = null;
  loading = true;

  ngOnInit(): void {
    this.api.getCategories().subscribe({
      next: (categories) => {
        this.categories = categories;
        this.loading = false;
      },
      error: () => { this.loading = false; },
    });
  }

  onCategorySelected(category: Category): void {
    if (category.id === this.selectedCategory?.id) return;

    if (this.store.hasChanges()) {
      this.dialog
        .open<ConfirmDialogComponent, ConfirmDialogData, boolean>(ConfirmDialogComponent, {
          data: {
            title: 'Discard unsaved changes?',
            message: 'You have unsaved edits in this category. Switching will discard them.',
            confirmText: 'Discard',
            cancelText: 'Keep editing',
          },
        })
        .afterClosed()
        .subscribe((confirmed) => {
          if (confirmed) {
            this.store.reset();
            this.selectedCategory = category;
          }
        });
      return;
    }

    this.selectedCategory = category;
  }
}

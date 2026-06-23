import { Component, EventEmitter, Input, OnChanges, Output, SimpleChanges } from '@angular/core';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatTreeModule } from '@angular/material/tree';
import { Category } from '../models/nexus.models';

export interface CategoryNode {
  category: Category;
  children: CategoryNode[];
}

/**
 * Category tree (single selection). Structure is read-only; selecting a node emits it.
 */
@Component({
  selector: 'nexus-sidebar',
  standalone: true,
  imports: [MatTreeModule, MatButtonModule, MatIconModule],
  templateUrl: './nexus-sidebar.component.html',
  styleUrl: './nexus-sidebar.component.scss',
})
export class NexusSidebarComponent implements OnChanges {
  @Input() categories: Category[] = [];
  /** Highlighted category id; driven by the parent so it stays in sync with the actual selection. */
  @Input() selectedId: number | null = null;
  @Output() categorySelected = new EventEmitter<Category>();

  treeData: CategoryNode[] = [];

  readonly childrenAccessor = (node: CategoryNode) => node.children;
  readonly hasChild = (_: number, node: CategoryNode) => node.children.length > 0;

  ngOnChanges(changes: SimpleChanges): void {
    // Only rebuild the tree when the category data changes. Rebuilding on every
    // input change (e.g. selectedId flowing back after a click) creates a new data
    // source, which resets the tree's expansion state and collapses the parent.
    if (changes['categories']) {
      this.treeData = this.buildTree(this.categories, null);
    }
  }

  select(category: Category): void {
    this.categorySelected.emit(category);
  }

  private buildTree(categories: Category[], parentId: number | null): CategoryNode[] {
    return categories
      .filter((c) => c.parentId === parentId)
      .sort((a, b) => a.sortOrder - b.sortOrder || a.displayName.localeCompare(b.displayName))
      .map((category) => ({ category, children: this.buildTree(categories, category.id) }));
  }
}

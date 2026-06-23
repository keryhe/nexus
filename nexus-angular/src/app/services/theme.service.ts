import { Injectable, signal } from '@angular/core';

const STORAGE_KEY = 'nexus-theme';

/** Light/dark theme toggle. Applies `.theme-dark` to <body> and persists the choice. */
@Injectable({ providedIn: 'root' })
export class ThemeService {
  readonly isDark = signal(false);

  constructor() {
    const stored = localStorage.getItem(STORAGE_KEY);
    this.apply(stored === 'dark');
  }

  toggle(): void {
    this.apply(!this.isDark());
  }

  private apply(dark: boolean): void {
    this.isDark.set(dark);
    document.body.classList.toggle('theme-dark', dark);
    localStorage.setItem(STORAGE_KEY, dark ? 'dark' : 'light');
  }
}

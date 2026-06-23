import { Component } from '@angular/core';
import { NexusPanelComponent } from './components/nexus-panel.component';

@Component({
  selector: 'app-root',
  imports: [NexusPanelComponent],
  template: '<nexus-panel />',
  styleUrl: './app.scss',
})
export class App {}

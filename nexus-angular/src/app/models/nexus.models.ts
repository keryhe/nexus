// Mirrors the camelCase JSON returned by Keryhe.Nexus.Api (/api/nexus/*).

export interface Category {
  id: number;
  parentId: number | null;
  name: string;
  displayName: string;
  sortOrder: number;
  sectionType: string;
}

export interface Section {
  id: number;
  parentId: number | null;
  categoryId: number;
  name: string;
  displayName: string;
  sortOrder: number;
  sectionType: string;
}

export interface Config {
  id: number;
  sectionId: number;
  name: string;
  displayName: string;
  sortOrder: number;
  dataType: string;
  value: string | null;
  isEncrypted: boolean;
  dropdownListId: number | null;
  dropdownListName: string | null;
  createdAt: string;
  updatedAt: string;
}

export interface DropdownListItem {
  id: number;
  name: string;
  value: string;
  sortOrder: number;
}

export interface UpdateConfigValueRequest {
  value: string | null;
  isEncrypted: boolean;
}

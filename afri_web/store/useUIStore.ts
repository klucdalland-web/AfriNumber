import { create } from 'zustand';

interface UiState {
  isMenuOpen: boolean;
  theme: "light" | "dark";
  language: "fr" | "en";
  toggleMenu: () => void;
  closeMenu: () => void;
  setTheme: (theme: "light" | "dark") => void;
  setLanguage: (language: "fr" | "en") => void;
}

export const useUiStore = create<UiState>((set) => ({
  isMenuOpen: false,
  theme: "light",
  language: "fr",
  toggleMenu: () => set((state) => ({ isMenuOpen: !state.isMenuOpen })),
  closeMenu: () => set({ isMenuOpen: false }),
  setTheme: (theme) => set({ theme }),
  setLanguage: (language) => set({ language }),
}));

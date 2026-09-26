"use client";

import { useEffect } from "react";
import { useUiStore } from "@/store/useUIStore";
import { Button } from "@/components/ui/button"; // Composant shadcn/ui
import { Menu, X, Moon, Sun } from "lucide-react";
import Image from "next/image";
const navItems = {
  fr: [
    { label: "Accueil", href: "#accueil" },
    { label: "Produit", href: "#produit" },
    { label: "Comment ça marche", href: "#comment-ca-marche" },
    { label: "À propos", href: "#a-propos" },
    { label: "Impact", href: "#impact" },
    { label: "FAQ", href: "#faq" },
  ],
  en: [
    { label: "Home", href: "#accueil" },
    { label: "Product", href: "#produit" },
    { label: "How it works", href: "#comment-ca-marche" },
    { label: "About", href: "#a-propos" },
    { label: "Impact", href: "#impact" },
    { label: "FAQ", href: "#faq" },
  ],
} as const;

export default function Navbar() {
  const {
    isMenuOpen,
    toggleMenu,
    closeMenu,
    theme,
    language,
    setTheme,
    setLanguage,
  } = useUiStore();
  const items = navItems[language];
  const ctaLabel = language === "fr" ? "Télécharger l'App" : "Download the App";

  useEffect(() => {
    const savedTheme = window.localStorage.getItem("afrinumber-theme");
    const savedLanguage = window.localStorage.getItem("afrinumber-language");
    const nextTheme = savedTheme === "dark" ? "dark" : "light";
    const nextLanguage = savedLanguage === "en" ? "en" : "fr";

    setTheme(nextTheme);
    setLanguage(nextLanguage);
    document.documentElement.classList.toggle("dark", nextTheme === "dark");
    document.documentElement.lang = nextLanguage;
  }, [setLanguage, setTheme]);

  const changeTheme = () => {
    const nextTheme = theme === "light" ? "dark" : "light";
    setTheme(nextTheme);
    window.localStorage.setItem("afrinumber-theme", nextTheme);
    document.documentElement.classList.toggle("dark", nextTheme === "dark");
  };

  const changeLanguage = () => {
    const nextLanguage = language === "fr" ? "en" : "fr";
    setLanguage(nextLanguage);
    window.localStorage.setItem("afrinumber-language", nextLanguage);
    document.documentElement.lang = nextLanguage;
  };

  const scrollToSection = (href: string) => {
    closeMenu();
    const target = document.querySelector(href);
    if (target) {
      target.scrollIntoView({ behavior: "smooth", block: "start" });
    }
  };

  const handleScroll = (e: React.MouseEvent<HTMLAnchorElement>, href: string) => {
    e.preventDefault();
    scrollToSection(href);
  };

  return (
    <header className="sticky top-0 z-50 w-full border-b border-border bg-background/80 backdrop-blur-md">
      <div className="mx-auto flex h-24 max-w-7xl items-center justify-between px-4 sm:px-6 lg:px-8">
        
        {/* Logo / Marque */}
        <a href="#accueil" onClick={(e) => handleScroll(e, "#accueil")} className="flex items-center gap-2 text-3xl font-extrabold tracking-tight text-foreground">
          <Image
            src="/images/logo-afrika.png"
            alt="Logo AfriNumber"
            width={60}
            height={60}
            sizes="50px"
            className="h-10 w-10 object-contain sm:h-12 sm:w-12"
          />
          <span>AfriNumber</span>
        </a>

        {/* Liens de Navigation Desktop */}
        <nav className="hidden items-center gap-6 text-base font-bold text-foreground md:flex">
          {items.map((item) => (
            <a
              key={item.href}
              href={item.href}
              onClick={(e) => handleScroll(e, item.href)}
              className="transition-colors hover:text-blue-600"
            >
              {item.label}
            </a>
          ))}
        </nav>

        {/* CTA Button Desktop */}
        <div className="hidden items-center gap-2 md:flex">
          <button
            type="button"
            onClick={changeLanguage}
            className="rounded-md px-2 py-2 text-xs font-bold text-foreground transition-colors hover:bg-muted"
            aria-label={language === "fr" ? "Passer en anglais" : "Switch to French"}
          >
            {language === "fr" ? "EN" : "FR"}
          </button>
          <button
            type="button"
            onClick={changeTheme}
            className="rounded-md p-2 text-foreground transition-colors hover:bg-muted"
            aria-label={theme === "light" ? "Activer le mode sombre" : "Activer le mode clair"}
          >
            {theme === "light" ? <Moon className="h-4 w-4" /> : <Sun className="h-4 w-4" />}
          </button>
          <Button
            className="bg-primary font-semibold text-primary-foreground hover:bg-primary/80"
            onClick={() => scrollToSection("#comment-ca-marche")}
          >
            {ctaLabel}
          </Button>
        </div>

        {/* Déclencheur Menu Mobile */}
        <button
          onClick={toggleMenu}
          className="rounded-md p-2 text-muted-foreground hover:bg-muted hover:text-foreground md:hidden"
          aria-label="Toggle menu"
        >
          {isMenuOpen ? <X className="h-6 w-6" /> : <Menu className="h-6 w-6" />}
        </button>
      </div>

      {/* Rideau Menu Mobile */}
      {isMenuOpen && (
        <div className="space-y-3 border-b border-border bg-background px-4 py-4 shadow-lg animate-in slide-in-from-top-5 duration-200 md:hidden">
          <div className="flex items-center gap-2 border-b border-border pb-3">
            <button
              type="button"
              onClick={changeLanguage}
              className="rounded-md px-2 py-2 text-xs font-bold text-foreground hover:bg-muted"
              aria-label={language === "fr" ? "Passer en anglais" : "Switch to French"}
            >
              {language === "fr" ? "EN" : "FR"}
            </button>
            <button
              type="button"
              onClick={changeTheme}
              className="rounded-md p-2 text-foreground hover:bg-muted"
              aria-label={theme === "light" ? "Activer le mode sombre" : "Activer le mode clair"}
            >
              {theme === "light" ? <Moon className="h-4 w-4" /> : <Sun className="h-4 w-4" />}
            </button>
          </div>
          {items.map((item) => (
            <a
              key={item.href}
              href={item.href}
              onClick={(e) => handleScroll(e, item.href)}
              className="block rounded-md px-3 py-2 text-base font-medium text-muted-foreground hover:bg-muted hover:text-blue-600"
            >
              {item.label}
            </a>
          ))}
          <div className="pt-2">
            <Button
              className="w-full bg-blue-600 hover:bg-blue-700 text-white"
              onClick={() => scrollToSection("#comment-ca-marche")}
            >
              {ctaLabel}
            </Button>
          </div>
        </div>
      )}
    </header>
  );
}

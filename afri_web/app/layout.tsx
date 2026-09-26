import type { Metadata } from "next";
import { Inter } from "next/font/google";
import "./globals.css";
import Navbar from "@/components/navbar";
import Footer from "@/components/footer";

const inter = Inter({
  variable: "--font-sans",
  subsets: ["latin"],
});

export const metadata: Metadata = {
  title: "AfriNumber",
  description: "Plateforme AfriNumber",
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
   
  return (
    <html lang="fr" className={`${inter.variable} scroll-smooth`}>
      <body className="flex min-h-screen flex-col bg-background text-foreground antialiased">
        {/* En-tête Global avec Zustand Store */}
        <Navbar />
        
        {/* Conteneur de la Page All-in-One */}
        <main className="w-full flex-1 pt-[4.75rem] sm:pt-20">
          {children}
        </main>

        {/* Pied de page Global */}
        <Footer />
      </body>
    </html>
  );
}

import type { Metadata } from "next";
import { Manrope } from "next/font/google";
import "./globals.css";
import Navbar from "@/components/navbar";
import Footer from "@/components/footer";

const manrope = Manrope({
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
    <html lang="fr" className={`${manrope.variable} scroll-smooth font-sans`}>
      <body className="flex min-h-screen flex-col bg-background text-foreground antialiased font-sans">
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

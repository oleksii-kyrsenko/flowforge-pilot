import type { Metadata } from "next";
import { Poppins } from "next/font/google";
import "./globals.css";

// Poppins is the confirmed primary font (design face) — applied ONCE, globally, as the
// document default via the --font-poppins custom property (CLAUDE.md §11 primary-font guard).
// next/font self-hosts it and populates --font-poppins on <html>, so the design token and
// the Tailwind `font-poppins` utility both resolve to the self-hosted face. Never per-component.
const poppins = Poppins({
  subsets: ["latin"],
  weight: ["300", "400", "500", "600", "700", "900"],
  display: "swap",
  variable: "--font-poppins",
});

export const metadata: Metadata = {
  title: "FlowForge",
  description: "FlowForge — from mockup to merge.",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en" className={`${poppins.variable} h-full antialiased`}>
      <body className="min-h-full flex flex-col">{children}</body>
    </html>
  );
}

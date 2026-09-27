import { NextResponse } from "next/server";

const apiBaseUrl = process.env.AFRISERVER_API_URL ?? "https://afriserver.onrender.com/api/v1";
const CACHE_SECONDS = 300;
const successCacheHeaders = {
  "Cache-Control": "public, max-age=60, s-maxage=300, stale-while-revalidate=600",
};
const noCacheHeaders = { "Cache-Control": "no-store" };

export async function GET() {
  const headers = new Headers({ Accept: "application/json" });
  const apiKey = process.env.AFRISERVER_API_KEY;
  const apiToken = process.env.AFRISERVER_API_TOKEN;

  if (apiKey) headers.set("x-api-key", apiKey);
  if (apiToken) headers.set("Authorization", `Bearer ${apiToken}`);

  try {
    const response = await fetch(`${apiBaseUrl.replace(/\/$/, "")}/pays`, {
      headers,
      next: { revalidate: CACHE_SECONDS },
      signal: AbortSignal.timeout(10_000),
    });
    if (response.status === 204) {
      return new NextResponse(null, { status: 204, headers: successCacheHeaders });
    }
    const payload = await response.json().catch(() => null);
    if (payload === null) {
      return NextResponse.json(
        { error: "Réponse invalide du service pays." },
        { status: response.ok ? 502 : response.status, headers: noCacheHeaders },
      );
    }

    return NextResponse.json(payload, {
      status: response.status,
      headers: response.ok ? successCacheHeaders : noCacheHeaders,
    });
  } catch {
    return NextResponse.json(
      { error: "Le service pays est temporairement indisponible." },
      { status: 502, headers: noCacheHeaders },
    );
  }
}

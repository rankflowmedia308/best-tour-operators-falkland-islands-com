export default function middleware(request) {
  const ua = (request.headers.get("user-agent") || "").toLowerCase();
  const blocked = ["ahrefsbot", "ahrefssiteaudit",
  "semrushbot", "semrushbot-si", "semrushbotbacklinkaudit", "siteauditbot",
  "mj12bot", "dotbot", "rogerbot", "blexbot", "serpstatbot", "dataforseobot"];
  if (blocked.some(bot => ua.includes(bot))) {
    return new Response("Forbidden", { status: 403 });
  }
  return new Response(null, { status: 200, headers: { 'x-middleware-next': '1' } });
}

export const config = { matcher: "/(.*)" };

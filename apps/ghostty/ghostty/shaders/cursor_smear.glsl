// Subtle cursor smear for Ghostty.
// Uses Ghostty's cursor uniforms, available in Ghostty 1.2.0+.

const float DURATION = 0.16;
const float OPACITY = 0.22;
const float MIN_DISTANCE_IN_CURSOR_HEIGHTS = 1.15;
const vec3 TRAIL_COLOR = vec3(0.827, 0.804, 0.765); // #d3cdc3

vec2 normalizeCoord(vec2 value, float isPosition) {
  return (value * 2.0 - (iResolution.xy * isPosition)) / iResolution.y;
}

float segmentDistance(vec2 p, vec2 a, vec2 b) {
  vec2 pa = p - a;
  vec2 ba = b - a;
  float h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
  return length(pa - ba * h);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
  vec4 base = texture(iChannel0, fragCoord.xy / iResolution.xy);
  fragColor = base;

  float elapsed = iTime - iTimeCursorChange;
  float progress = clamp(elapsed / DURATION, 0.0, 1.0);
  float fade = pow(1.0 - progress, 2.0);
  if (fade <= 0.0) {
    return;
  }

  vec4 current = vec4(
    normalizeCoord(iCurrentCursor.xy, 1.0),
    normalizeCoord(iCurrentCursor.zw, 0.0)
  );
  vec4 previous = vec4(
    normalizeCoord(iPreviousCursor.xy, 1.0),
    normalizeCoord(iPreviousCursor.zw, 0.0)
  );

  vec2 currentCenter = vec2(current.x + current.z * 0.5, current.y - current.w * 0.5);
  vec2 previousCenter = vec2(previous.x + previous.z * 0.5, previous.y - previous.w * 0.5);

  float cursorHeight = max(current.w, 0.0001);
  float travel = distance(currentCenter, previousCenter);
  if (travel < cursorHeight * MIN_DISTANCE_IN_CURSOR_HEIGHTS) {
    return;
  }

  vec2 p = normalizeCoord(fragCoord.xy, 1.0);
  float radius = max(current.z, current.w) * 0.34;
  float feather = normalizeCoord(vec2(2.0, 0.0), 0.0).x;
  float mask = 1.0 - smoothstep(radius, radius + feather, segmentDistance(p, currentCenter, previousCenter));
  float alpha = mask * fade * OPACITY;

  fragColor = mix(base, vec4(TRAIL_COLOR, base.a), alpha);
}

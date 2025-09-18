function drawSphereMeridians(win, cx, cy, R, nLines, angle, color, lineW, frontCull)
% Vertical-looking "curved lines" (meridians) on a rotating sphere.
% Parametric unit sphere:
%   x =  sin(t)cos(phi), y = cos(t), z = sin(t)sin(phi)
% Screen projection: (cx + R*x, cy - R*y). Cull z<0 if frontCull.

t = linspace(0, pi, 400);
for k = 1:nLines
    phi = 2*pi*k/nLines + angle;
    x = R * sin(t) .* cos(phi);
    y = R * cos(t);
    z = R * sin(t) .* sin(phi);

    if frontCull
        keep = (z >= 0);
        x = x(keep); y = y(keep);
    end
    if ~isempty(x)
        Screen('DrawLines', win, [cx + x; cy - y], lineW, color);
    end
end
end

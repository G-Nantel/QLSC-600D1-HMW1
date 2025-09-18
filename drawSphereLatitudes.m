function drawSphereLatitudes(win, cx, cy, R, nLines, angle, color, lineW, frontCull)
% Horizontal-looking "curved lines" (latitudes) on a rotating sphere.
% Rotated parameterization:
%   x = cos(t), y = sin(t)cos(phi), z = sin(t)sin(phi)

t = linspace(0, pi, 400);
for k = 1:nLines
    phi = 2*pi*k/nLines + angle;
    x = R * cos(t);
    y = R * sin(t) .* cos(phi);
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

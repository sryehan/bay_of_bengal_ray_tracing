%% File
ncfile = 'C:\Users\Lenovo\Downloads\soma\sst.day.mean.2025.nc';

%% Read variables
lon = ncread(ncfile,'lon');   % [-359.875 .. -0.125]
lat = ncread(ncfile,'lat');   % [-89.875 .. 89.875]
sst = ncread(ncfile,'sst');   % (lon x lat x time)

% Select one day
sst_day = squeeze(sst(:,:,1));

%% Convert longitude from [-360..0] → [0..360]
lon(lon < 0) = lon(lon < 0) + 360;

%% Subset Bay of Bengal region (75–95E, 5–25N)
lon_idx = lon >= 75 & lon <= 95;
lat_idx = lat >= 5  & lat <= 25;

lon_bob = lon(lon_idx);
lat_bob = lat(lat_idx);

sst_bob = sst_day(lon_idx, lat_idx);

%% Make meshgrid
[Lon,Lat] = meshgrid(lon_bob, lat_bob);

%% Plot
figure;
contourf(Lon, Lat, sst_bob', 100, 'LineColor','none'); % লেভেল 100
colorbar; 
colormap(turbo);   % jet এর থেকে smooth, চাইলে parula বা অন্য ব্যবহার করো
xlabel('Longitude'); ylabel('Latitude');
title('Bay of Bengal SST (°C)');

%% Add coastlines
hold on
load coastlines
plot(coastlon, coastlat, 'k','LineWidth',1.2);
axis([75 95 5 25])
grid on

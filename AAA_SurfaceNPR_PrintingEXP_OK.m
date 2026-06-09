%% V2：实现基础的模型导入，轨迹生成，机械臂可执行文件生成
% 五个手指的一笔画单层填充路径生成

%功能：热场路径优化为一笔画打印（针对只有一个局部值的情况）
%对机械臂三个pose进行实时存储并加载
%导入试验所需模型并进行整理。
%优化一下代码布局，功能区解耦

clc;
clear;
close all

%% 1.1.文件导入 （拇指，基底＋曲面+NPR区域）
% 绘制世界坐标系
plot_coordinate_frame(eye(3), [0;0;0], 15, '世界坐标系');
%导入基底模型 
ModelBase = stlread('.\01_BaseModels\Thumb_Base.STL');%读入你的stl文件，得到三角网格
F_Base = ModelBase.faces;
X_Base = ModelBase.vertices;
showMesh(ModelBase.faces,ModelBase.vertices);
%导入针头模型 
ModelNozzle = stlread('.\02_OtherModel\NozzleSimplify.STL');%读入你的stl文件，得到三角网格
F_Nozzle = ModelNozzle.faces;
X_Nozzle = ModelNozzle.vertices;
% showMesh(ModelNozzle.faces,ModelNozzle.vertices);
%导入切片曲面模型01
name1 = '.\03_Surfaces\Thumb_SurfaceNPR01.obj';
options.name = name1; % useful for displaying
[F_Surface01,X_Surface01] = read_obj(name1);
showMesh(F_Surface01,X_Surface01);
%导入切片曲面模型02
name2 = '.\03_Surfaces\Thumb_SurfaceNPR02.obj';
options.name = name2; % useful for displaying
[F_Surface02,X_Surface02] = read_obj(name2);
showMesh(F_Surface02,X_Surface02);

%Tips Location (第一个点为原点，第二个点为X轴，逆时针排列)★（后续用于机械臂的坐标转换）
Tips = [0,0,0;
       24,0,0;
       24,47,0];
MName = 'Thumb_SurfaceNPR';
pathMethod = 3;%路径方法%★
NearStartPoint = [20 23 -1.4];%路径起点近点%★
%参数化所需节点
pintscorner = [4.74023,28.3626,4.81026;
               15.0739,25.537,2.446;
               17.7429,32.5804,4.07693;
               7.56309,34.3077,7.01544];
corner = [];
for i = 1:length(pintscorner(:,1))
    p = pintscorner(i,:);        % 要查找的点
    tol = 1e-6;                 % 容差（根据数据精度调整）
    % 计算 V 中每个点到 p 的欧氏距离
    distances = sqrt(sum((X_Surface02-p).^2,2));  % R2017b+，或用 sqrt(sum((V-p).^2,2))
    [a,idx] = min(distances);
    if isempty(idx)
        disp('未找到匹配的点');
    elseif length(idx) == 1
        fprintf('点 [%g, %g, %g] 的索引是: %d\n', p, idx);
        corner = [corner;idx];
    else
        warning('找到多个匹配点！');
    end
end

%% 1.1.文件导入 （食指，基底＋曲面+NPR区域）
% 绘制世界坐标系
plot_coordinate_frame(eye(3), [0;0;0], 15, '世界坐标系');
%导入基底模型 
ModelBase = stlread('.\01_BaseModels\Index_Finger_Base.STL');%读入你的stl文件，得到三角网格
F_Base = ModelBase.faces;
X_Base = ModelBase.vertices;
showMesh(ModelBase.faces,ModelBase.vertices);
%导入针头模型 
ModelNozzle = stlread('.\02_OtherModel\NozzleSimplify.STL');%读入你的stl文件，得到三角网格
F_Nozzle = ModelNozzle.faces;
X_Nozzle = ModelNozzle.vertices;
% showMesh(ModelNozzle.faces,ModelNozzle.vertices);
%导入切片曲面模型01
name1 = '.\03_Surfaces\Index_Finger_surfaceoffset05NPR01.obj';
options.name = name1; % useful for displaying
[F_Surface01,X_Surface01] = read_obj(name1);
showMesh(F_Surface01,X_Surface01);

%导入切片曲面模型02
name2 = '.\03_Surfaces\Index_Finger_surfaceoffset05NPR02.obj';
options.name = name2; % useful for displaying
[F_Surface02,X_Surface02] = read_obj(name2);
showMesh(F_Surface02,X_Surface02);

%Tips Location (第一个点为原点，第二个点为X轴，逆时针排列)★（后续用于机械臂的坐标转换）
Tips = [0,0,0;
       20,0,0;
       20,47,0];
MName = 'Index_Finger_NPR';
pathMethod = 3;%路径方法%★
NearStartPoint = [17 23 3];%路径起点近点%★
%参数化所需节点
pintscorner = [4.99795,15.0191,6.55354;
               16.4171,16.044,4.41075;
               15.0706,25.6787,5.32864;
               4.61475,24.3971,7.18141];
corner = [];
for i = 1:length(pintscorner(:,1))
    p = pintscorner(i,:);        % 要查找的点
    tol = 1e-6;                 % 容差（根据数据精度调整）
    % 计算 V 中每个点到 p 的欧氏距离
    distances = sqrt(sum((X_Surface02-p).^2,2));  % R2017b+，或用 sqrt(sum((V-p).^2,2))
    [a,idx] = min(distances);
    if isempty(idx)
        disp('未找到匹配的点');
    elseif length(idx) == 1
        fprintf('点 [%g, %g, %g] 的索引是: %d\n', p, idx);
        corner = [corner;idx];
    else
        warning('找到多个匹配点！');
    end
end


%% 1.1.文件导入 （中指，基底＋曲面+NPR区域）
% 绘制世界坐标系
plot_coordinate_frame(eye(3), [0;0;0], 15, '世界坐标系');
%导入基底模型 
ModelBase = stlread('.\01_BaseModels\Midle_Finger_Base.STL');%读入你的stl文件，得到三角网格
F_Base = ModelBase.faces;
X_Base = ModelBase.vertices;
showMesh(ModelBase.faces,ModelBase.vertices);
%导入针头模型 
ModelNozzle = stlread('.\02_OtherModel\NozzleSimplify.STL');%读入你的stl文件，得到三角网格
F_Nozzle = ModelNozzle.faces;
X_Nozzle = ModelNozzle.vertices;
% showMesh(ModelNozzle.faces,ModelNozzle.vertices);
%导入切片曲面模型01
name1 = '.\03_Surfaces\Midle_Finger_SurfaceNPR01.obj';
options.name = name1; % useful for displaying
[F_Surface01,X_Surface01] = read_obj(name1);
showMesh(F_Surface01,X_Surface01);
%导入切片曲面模型02
name2 = '.\03_Surfaces\Midle_Finger_SurfaceNPR02.obj';
options.name = name2; % useful for displaying
[F_Surface02,X_Surface02] = read_obj(name2);
showMesh(F_Surface02,X_Surface02);

%Tips Location (第一个点为原点，第二个点为X轴，逆时针排列)★（后续用于机械臂的坐标转换）
Tips = [0,0,0;
       20,0,0;
       20,55,0];
MName = 'Midle_Finger_SurfaceNPR';
pathMethod = 3;%路径方法%★
NearStartPoint = [21 10 -0.5];%路径起点近点%★
%参数化所需节点
pintscorner = [4.47605,28.0448,3.89647;
               17.7125,28.5652,2.55586;
               17.2479,42.3092,2.91766;
               5.17463,41.6686,3.67375];
corner = [];
for i = 1:length(pintscorner(:,1))
    p = pintscorner(i,:);        % 要查找的点
    tol = 1e-6;                 % 容差（根据数据精度调整）
    % 计算 V 中每个点到 p 的欧氏距离
    distances = sqrt(sum((X_Surface02-p).^2,2));  % R2017b+，或用 sqrt(sum((V-p).^2,2))
    [a,idx] = min(distances);
    if isempty(idx)
        disp('未找到匹配的点');
    elseif length(idx) == 1
        fprintf('点 [%g, %g, %g] 的索引是: %d\n', p, idx);
        corner = [corner;idx];
    else
        warning('找到多个匹配点！');
    end
end



%% 1.1.文件导入 （无名指，基底＋曲面+NPR区域，需要V1版本一笔画路径）
% 绘制世界坐标系
plot_coordinate_frame(eye(3), [0;0;0], 15, '世界坐标系');
%导入基底模型 
ModelBase = stlread('.\01_BaseModels\Ring_Finger_Base.STL');%读入你的stl文件，得到三角网格
F_Base = ModelBase.faces;
X_Base = ModelBase.vertices;
showMesh(ModelBase.faces,ModelBase.vertices);
%导入针头模型 
ModelNozzle = stlread('.\02_OtherModel\NozzleSimplify.STL');%读入你的stl文件，得到三角网格
F_Nozzle = ModelNozzle.faces;
X_Nozzle = ModelNozzle.vertices;
% showMesh(ModelNozzle.faces,ModelNozzle.vertices);
%导入切片曲面模型01
name1 = '.\03_Surfaces\Ring_Finger_SurfaceNPR01.obj';
options.name = name1; % useful for displaying
[F_Surface01,X_Surface01] = read_obj(name1);
showMesh(F_Surface01,X_Surface01);
%导入切片曲面模型02
name2 = '.\03_Surfaces\Ring_Finger_SurfaceNPR02.obj';
options.name = name2; % useful for displaying
[F_Surface02,X_Surface02] = read_obj(name2);
showMesh(F_Surface02,X_Surface02);


%Tips Location (第一个点为原点，第二个点为X轴，逆时针排列)★（后续用于机械臂的坐标转换）
Tips = [0,0,0;
       18,0,0;
       18,55,0];
MName = 'Ring_Finger_SurfaceNPR';
pathMethod = 3;%路径方法%★
NearStartPoint = [15.65 25.60 2.80];%路径起点近点%★
%参数化所需节点
pintscorner = [1.80371,19.7733,5.20428;
               13.1754,18.5792,4.21717;
               13.0993,34.3931,4.39962;
               2.97255,33.4986,4.89427];
corner = [];
for i = 1:length(pintscorner(:,1))
    p = pintscorner(i,:);        % 要查找的点
    tol = 1e-6;                 % 容差（根据数据精度调整）
    % 计算 V 中每个点到 p 的欧氏距离
    distances = sqrt(sum((X_Surface02-p).^2,2));  % R2017b+，或用 sqrt(sum((V-p).^2,2))
    [a,idx] = min(distances);
    if isempty(idx)
        disp('未找到匹配的点');
    elseif length(idx) == 1
        fprintf('点 [%g, %g, %g] 的索引是: %d\n', p, idx);
        corner = [corner;idx];
    else
        warning('找到多个匹配点！');
    end
end




%% 1.1.文件导入 （小拇指，基底+曲面+NPR区域）
% 绘制世界坐标系
plot_coordinate_frame(eye(3), [0;0;0], 15, '世界坐标系');
%导入基底模型 
ModelBase = stlread('.\01_BaseModels\little_finger_Base.STL');%读入你的stl文件，得到三角网格
F_Base = ModelBase.faces;
X_Base = ModelBase.vertices;
showMesh(ModelBase.faces,ModelBase.vertices);
%导入针头模型 
ModelNozzle = stlread('.\02_OtherModel\NozzleSimplify.STL');%读入你的stl文件，得到三角网格
F_Nozzle = ModelNozzle.faces;
X_Nozzle = ModelNozzle.vertices;
% showMesh(ModelNozzle.faces,ModelNozzle.vertices);
%导入切片曲面模型01
name1 = '.\03_Surfaces\little_finger_SurfaceNPR01.obj';
options.name = name1; % useful for displaying
[F_Surface01,X_Surface01] = read_obj(name1);
showMesh(F_Surface01,X_Surface01);
%导入切片曲面模型02
name2 = '.\03_Surfaces\little_finger_SurfaceNPR02.obj';
options.name = name2; % useful for displaying
[F_Surface02,X_Surface02] = read_obj(name2);
showMesh(F_Surface02,X_Surface02);

%Tips Location (第一个点为原点，第二个点为X轴，逆时针排列)★（后续用于机械臂的坐标转换）
Tips = [0,0,0;
       16,0,0;
       16,35,0];
MName = 'little_finger_SurfaceNPR';
pathMethod = 3;%路径方法%★
NearStartPoint = [14 16 2.3];%路径起点近点%★
%参数化所需节点
pintscorner = [4.01555,10.838,1.47363;
               11.0822,10.5128,2.17823;
               13.0054,25.0467,2.276;
               4.45497,24.8878,1.42072];
corner = [];
for i = 1:length(pintscorner(:,1))
    p = pintscorner(i,:);        % 要查找的点
    tol = 1e-6;                 % 容差（根据数据精度调整）
    % 计算 V 中每个点到 p 的欧氏距离
    distances = sqrt(sum((X_Surface02-p).^2,2));  % R2017b+，或用 sqrt(sum((V-p).^2,2))
    [a,idx] = min(distances);
    if isempty(idx)
        disp('未找到匹配的点');
    elseif length(idx) == 1
        fprintf('点 [%g, %g, %g] 的索引是: %d\n', p, idx);
        corner = [corner;idx];
    else
        warning('找到多个匹配点！');
    end
end
%% 曲面偏移===========================================001===========================================
%%% 2.0.曲面切片=================================================================
%根据Surface和一些曲面参数配置生成曲面切片需要的曲面集合
offsetDistance = 0.45;
[S01,normals01] = surfaceOffset(F_Surface01,X_Surface01,offsetDistance);
[S02,normals02] = surfaceOffset(F_Surface02,X_Surface02,offsetDistance);
hold on
trisurf(S01.faces, S01.vertices(:,1),S01.vertices(:,2),S01.vertices(:,3),'FaceAlpha', 0.3, 'FaceColor', 'b');
trisurf(S02.faces, S02.vertices(:,1),S02.vertices(:,2),S02.vertices(:,3),'FaceAlpha', 0.3, 'FaceColor', 'b');
xlabel('X');
ylabel('Y');
zlabel('Z');
axis('tight');
%对曲面集合进行自相交处理★(自相交处理存在BUG后续优化)

%%% 参数化生成负泊松比区域（NEW）======================002============================================
v = S02.vertices;
f = S02.faces;
% visualize the input mesh with the specified corners
plot_mesh(v,f); 
view([0 90]); hold on;
plot3(v(corner(1),1),v(corner(1),2),v(corner(1),3),'ro','MarkerFaceColor','r');
plot3(v(corner(2),1),v(corner(2),2),v(corner(2),3),'go','MarkerFaceColor','g');
plot3(v(corner(3),1),v(corner(3),2),v(corner(3),3),'bo','MarkerFaceColor','b');
plot3(v(corner(4),1),v(corner(4),2),v(corner(4),3),'yo','MarkerFaceColor','y');

% compute the rectangular conformal map
map = rectangular_conformal_map(v,f,corner);

% visualize the rectangular conformal map with the specified corners
plot_mesh(map,f); 
hold on;
plot(map(corner(1),1),map(corner(1),2),'ro','MarkerFaceColor','r');
plot(map(corner(2),1),map(corner(2),2),'go','MarkerFaceColor','g');
plot(map(corner(3),1),map(corner(3),2),'bo','MarkerFaceColor','b');
plot(map(corner(4),1),map(corner(4),2),'yo','MarkerFaceColor','y');


[x,y] = meshgrid(0:0.0025:max(map(:,1)),0:0.0025:max(map(:,2)));
I = zeros(size(x,1),size(x,2),3);
I(:,:,1) = 0.55;
I(:,:,2) = 0.25;
I(:,:,3) = 0.2;
for i = 1:size(x,1)
    for j = 1:size(x,2)
        if (mod(round(x(i,j)*20),2) == 1 && mod(round(y(i,j)*20),2) == 1) || (mod(round(x(i,j)*20),2) == 0 && mod(round(y(i,j)*20),2) == 0)
            I(i,j,1) = 1;
            I(i,j,2) = 0.85;
            I(i,j,3) = 0.65;
        end
    end
end
figure;
imshow(I);

% map the texture onto the surface using the parameterization result
% F1 = TriScatteredInterp(map,v(:,1),'natural'); % for older versions of MATLAB
% F2 = TriScatteredInterp(map,v(:,2),'natural'); % for older versions of MATLAB
% F3 = TriScatteredInterp(map,v(:,3),'natural'); % for older versions of MATLAB
F1 = scatteredInterpolant(map,v(:,1),'natural');
F2 = scatteredInterpolant(map,v(:,2),'natural');
F3 = scatteredInterpolant(map,v(:,3),'natural');
X = F1(x,y);
Y = F2(x,y);
Z = F3(x,y);

% visualize the texture mapping result
figure;
surf(X,Y,Z,'FaceColor','texturemap','Cdata',I);
shading interp
set(gcf,'color','w'); 
axis equal tight off
ax = gca; ax.Clipping = 'off';
view([0 90])
% --- 参数设置 ---
grid_size_u = 5; % u 方向（通常是 map 的第一列 x 坐标）的格子数
grid_size_v = 5; % v 方向（通常是 map 的第二列 y 坐标）的格子数
% 获取参数域范围 (使用你实际计算出的 map 范围)
u_min = min(map(:, 1));
u_max = max(map(:, 1));
v_min = min(map(:, 2));
v_max = max(map(:, 2));
%=============打印线条参数=================
d = 10;               % 控制正弦波的间距(线距)
lineNumV = grid_size_v; % 控制正弦波的线条数量★
lineNumU = grid_size_u; % 控制正弦波的线条数量★
linwidth = 0.41;       %线条宽度
steplength = 0.15;     %路径点插值★
offset = [d/2,d/2];
scaleU = (u_max-u_min)/(d*lineNumU);
scaleV = (v_max-v_min)/(d*lineNumV);
% ==============多振幅pattern var===================
start_val = 0.6;
mid_val = 0.2;
end_val = 0.6;
step_size = 0.06; % 例如，步长为 0.1
if step_size <= 0
    error('步长必须为正数');
end
segment1 = start_val : -step_size : mid_val;
segment2 = mid_val : step_size : end_val;
result_array = [segment1, segment2(1:end)]; % 去掉重复的 mid_val
pattern = result_array;
denominator = [pattern,pattern,pattern];% 振幅控制器
% ========================================================================
% ====                    用户配置区                              ====
% ========================================================================
% 在此处修改波形类型和相关参数来生成不同的图案
% --- 基础波形 ---
% wave_type_col = 'sine';
% wave_type_col = 'cosine';
% wave_type_col = 'abs_sine';
% wave_type_col = 'abs_cosine';
% wave_type_col = 'sine_squared';
% wave_type_col = 'cosine_squared';
% wave_type_col = 'sine_cubed';
% wave_type_col = 'cosine_cubed';
% wave_type_col = 'sine_plus_cosine';
% wave_type_col = 'sine_times_cosine';
% --- 特殊波形 ---
% wave_type_col = 'tangent'; % 注意可能的不连续性
% wave_type_col = 'square';
% wave_type_col = 'sawtooth';
% wave_type_col = 'triangle';
% wave_type_col = 'sinc';
% --- 需要额外参数的波形 ---
% wave_type_col = 'gaussian_envelope_sine'; sigma_col = 1.5;
% wave_type_col = 'damped_sine'; alpha_col = 0.05;
% wave_type_col = 'custom_sin_plus_sin'; amp2_col=0.5; freq_mult2_col=3; phase2_col=pi/4;
% --- 新增高级波形 ---
% wave_type_col = 'fm_sine'; freq_dev_col = 1.0; mod_freq_col = pi/15;
% wave_type_col = 'pm_sine'; phase_dev_col = 2.0; mod_freq_col = pi/20;
% wave_type_col = 'fourier_series_square'; fourier_N_col = 5;
% wave_type_col = 'fourier_series_sawtooth'; fourier_N_col = 7;
% wave_type_col = 'random_amplitude_sine'; noise_level_col = 0.2; % 20% 振幅扰动
% wave_type_col = 'random_frequency_sine'; noise_level_col = 0.1; % 10% 频率扰动
% wave_type_col = 'sine_of_sine';
% wave_type_col = 'cosine_of_sine';
% wave_type_col = 'chirp_linear'; end_freq_factor_col = pi/2; % 结束频率因子
% wave_type_col = 'chirp_exponential'; end_freq_factor_col = pi/3;
wave_type_col = 'sine_cubed'; % <<<=== 修改这里尝试不同列波形 ===>>>（实际是每一行）
wave_type_row = 'sine_cubed';   % <<<=== 修改这里尝试不同行波形 ===>>>（实际是每一列）
% ==============pathgen var====================
Zin = 0;
Zdelta = 0.6*linwidth;%单层不同图案微抬针mm
layersNum = length(denominator);%层数
% ==============路径生成（单振幅）==========================
ALLpath = [];

Z = Zin+Zdelta*1; %Z轴高度
%=================路径生成==================
lineNum = grid_size_v;   % 行列线条数量（推荐奇数）
d = d;                   % 控制正弦波的间距(线距)
p = steplength;              % 控制生成点的步长
ax = denominator(1);             % 列方向振幅系数
ay = denominator(1);             % 行方向振幅系数
wx = 1;               % 列方向频率因子倍数 (1.5 个周期 -> 1.5)★
wy = 1;               % 行方向频率因子倍数 (0.5 个周期 -> 0.5)★
[Path_col,Path_row,PointPre_COL,PointPre_ROW] = AuxeticGeneratorV3(lineNumU,lineNumV,d,p,ax,ay,wx,wy,wave_type_col,wave_type_row);
Path_row = fliplr(Path_row);
%同一层行与列之间进行圆弧连接
onelayerPath = [Path_col';Path_row'];
onelayerPath = remove_adjacent_duplicates(onelayerPath);
onelayerPath = resample_path_fixed_step_global(onelayerPath, steplength);
ALLpath = [ALLpath;onelayerPath];
figure;
plot(ALLpath(:,1),ALLpath(:,2),'k-');

% ==============路径映射到曲面==========================
ALLpath(:,1) = ALLpath(:,1)*scaleU;
ALLpath(:,2) = ALLpath(:,2)*scaleV;
path_points_uv = ALLpath;
figure;
plot(ALLpath(:,1),ALLpath(:,2),'r-');

% 执行映射：将参数域的点 (u, v) 映射为 3D 坐标 (x, y, z)
try
    x_path_3D = F1(path_points_uv(:, 1), path_points_uv(:, 2));
    y_path_3D = F2(path_points_uv(:, 1), path_points_uv(:, 2));
    z_path_3D = F3(path_points_uv(:, 1), path_points_uv(:, 2));
catch ME
    error('映射到 3D 空间时出错: %s', ME.message);
end

% --- 3. 可视化结果 ---

% --- 3a. 显示参数域中的弓字型路径 ---
figure; % 新开一个 Figure 窗口
% 绘制参数化后的网格 (浅色背景)
plot_mesh(map,f); 
hold on;
% 绘制弓字型路径
plot(path_points_uv(:, 1), path_points_uv(:, 2), 'b-', 'LineWidth', 1.5);
% 标记起点和终点
plot(path_points_uv(1, 1), path_points_uv(1, 2), 'go', 'MarkerSize', 6, 'MarkerFaceColor', 'g'); % 起点 绿色圆圈
plot(path_points_uv(end, 1), path_points_uv(end, 2), 'rs', 'MarkerSize', 6, 'MarkerFaceColor', 'r'); % 终点 红色方块
title('Parameter Domain with Bow-Fill Path');
xlabel('U Parameter');
ylabel('V Parameter');
axis equal tight;
grid on;
legend('Mesh (Parameterized)', 'Bow-Fill Path', 'Start', 'End', 'Location', 'bestoutside');


% --- 3b. 显示映射回 3D 模型后的弓字型路径 ---
figure; % 再开一个新的 Figure 窗口
% 先绘制 3D 模型 (这里使用之前的纹理映射结果，你也可以用原始网格)
% hSurf = surf(X,Y,Z,'FaceColor','texturemap','CData',I); % 如果你保留了 X,Y,Z,I
% shading interp; % 如果用了纹理映射 surf

% 或者重新绘制原始网格 (推荐，更清晰)
hsurf_model = patch('Faces', f, 'Vertices', v, 'FaceColor', 'cyan', 'EdgeColor', 'none', 'FaceAlpha', 0.6);
% 或者如果你想要带边界的网格: patch('Faces', f, 'Vertices', v, 'FaceColor', 'interp', 'EdgeColor', 'black', 'LineWidth', 0.5);

hold on;
% 绘制 3D 路径线
hpath_3d = plot3(x_path_3D, y_path_3D, z_path_3D, 'k-', 'LineWidth', 2); % 黑色实线
% 标记起点和终点
hstart_3d = plot3(x_path_3D(1), y_path_3D(1), z_path_3D(1), 'go', 'MarkerSize', 8, 'MarkerFaceColor', 'g'); % 起点 绿色圆圈
hend_3d = plot3(x_path_3D(end), y_path_3D(end), z_path_3D(end), 'rs', 'MarkerSize', 8, 'MarkerFaceColor', 'r'); % 终点 红色方块

% 设置图形属性
% shading interp; % 如果用了纹理映射 surf
set(gcf, 'Color', 'w');
daspect([1 1 1]); % 保持 XYZ 轴比例一致 (可选，取决于模型比例)
axis tight;
camlight; % 添加光照增强立体感 (可选)
lighting gouraud; % 设置光照模式 (可选)
title('3D Model with Mapped Bow-Fill Path');
xlabel('X'); ylabel('Y'); zlabel('Z');
view(3); % 设置为 3D 视角
grid on;
legend([hsurf_model, hpath_3d, hstart_3d, hend_3d], {'Model', 'Bow-Fill Path', 'Start', 'End'}, 'Location', 'bestoutside');
Path3D = [x_path_3D,y_path_3D,z_path_3D];
startpointNPR = Path3D(1,:);%取路径首尾点
NearStartPoint = startpointNPR;
Path3D(:,4) = 1;%全程打印标记
%%% 热法路径生成=======================================003=========================================
%%% 3.0.基于热场的一笔画路径生成(抬针）==========================================
% 生成路径
stpLength = 0.4;%路径间距%★
startvalue = stpLength*0.2;
%pathMethod = input('请移动机械臂TCP到第一个尖点 (1-通用抬针, 2-一笔画V0, 3-一笔画V1: ');
switch pathMethod
    case 1
       % 存在抬针
       lift_height = 5;
       [ALLLLLLOnePath_new] = HeatField2PathV0(name1,stpLength,lift_height,startvalue);
    case 2 
        %一笔螺旋V0（只有一个局部点的情况）
        [G_ALLLLLLOnePath_new,ALLLLLLOnePath_new] = MyOnePathGenaratorV0(name1,stpLength,NearStartPoint,startvalue);%生成路径点
        ALLLLLLOnePath_new(:,4) = 1;
    case 3 
        %一笔螺旋V1（只有多个局部点的情况，不是很稳定需要进一步优化）
        figure;
 %       [G_ALLLLLLOnePath_new,ALLLLLLOnePath_new] = MyOnePathGenaratorV1(name1,stpLength,NearStartPoint,startvalue);% 这个版本仍然存在一个BUG需要后续进行优化
        F_new = S01.faces;
        V_new = S01.vertices;
        [G_ALLLLLLOnePath_new,ALLLLLLOnePath_new] =  MyOnePathGenaratorV2TestA(F_new,V_new,stpLength,NearStartPoint,startvalue);
        ALLLLLLOnePath_new(:,4) = 1;
end

figure;
hold on;
plot3(ALLLLLLOnePath_new(:,1),ALLLLLLOnePath_new(:,2),ALLLLLLOnePath_new(:,3),'b-');

%%% 分配法向===========================================004=============================================
% 显示路径 
figure; hold on
plot3(ALLLLLLOnePath_new(:,1),ALLLLLLOnePath_new(:,2),ALLLLLLOnePath_new(:,3),'k-');
Flag01 = ALLLLLLOnePath_new(:,4);
showNum = 4;
scatter3(ALLLLLLOnePath_new(1:1+showNum,1),ALLLLLLOnePath_new(1:1+showNum,2),ALLLLLLOnePath_new(1:1+showNum,3),'blue','filled');
scatter3(ALLLLLLOnePath_new(end-4:end,1),ALLLLLLOnePath_new(end-showNum:end,2),ALLLLLLOnePath_new(end-showNum:end,3),'red','filled');
% 为路径点添加法向
orderALLPoints01 = ALLLLLLOnePath_new(:,1:3);
point_normals01 = assignPointNormalsFast(orderALLPoints01, S01.vertices, S01.faces, normals01);
% 将法向信息添加到路径中
orderALLPoints_with_normals01 = [orderALLPoints01, point_normals01];
figure;
%法向量显示
plot3(orderALLPoints_with_normals01(:,1), orderALLPoints_with_normals01(:,2), ...
      orderALLPoints_with_normals01(:,3),'b-');
hold on;
quiver3(orderALLPoints_with_normals01(:,1), orderALLPoints_with_normals01(:,2), ...
        orderALLPoints_with_normals01(:,3), orderALLPoints_with_normals01(:,4), ...
        orderALLPoints_with_normals01(:,5), orderALLPoints_with_normals01(:,6));



% 显示路径 
figure; hold on
plot3(Path3D(:,1),Path3D(:,2),Path3D(:,3),'k-');
Flag02 = Path3D(:,4);
showNum = 4;
scatter3(Path3D(1:1+showNum,1),Path3D(1:1+showNum,2),Path3D(1:1+showNum,3),'blue','filled');
scatter3(Path3D(end-4:end,1),Path3D(end-showNum:end,2),Path3D(end-showNum:end,3),'red','filled');
% 为路径点添加法向
orderALLPoints02 = Path3D(:,1:3);
point_normals02 = assignPointNormalsFast(orderALLPoints02, S02.vertices, S02.faces, normals02);
% 将法向信息添加到路径中
orderALLPoints_with_normals02 = [orderALLPoints02, point_normals02];

figure;
%法向量显示
plot3(orderALLPoints_with_normals02(:,1), orderALLPoints_with_normals02(:,2), ...
      orderALLPoints_with_normals02(:,3),'b-');
hold on;
quiver3(orderALLPoints_with_normals02(:,1), orderALLPoints_with_normals02(:,2), ...
        orderALLPoints_with_normals02(:,3), orderALLPoints_with_normals02(:,4), ...
        orderALLPoints_with_normals02(:,5), orderALLPoints_with_normals02(:,6));


%%% 路径合并===========================================005=========================================


%%% 3.1.路径稀疏采样处理========================================================
points = orderALLPoints_with_normals01;
% 调用重采样函数
target_spacing = 1.2; % 根据实际情况调整
coord_points = points(:, 1:3);
normal_vectors = points(:, 4:6);
flags = Flag01;
%[interp_points, interp_normals] = uniformResamplePath(coord_points, normal_vectors, target_spacing);
[interp_points, interp_normals, interp_flags] = uniformResamplePath2(coord_points, normal_vectors, target_spacing, flags);
ResamplePath01 = [interp_points,interp_normals];

points = orderALLPoints_with_normals02;
% 调用重采样函数
target_spacing = 0.3; % 根据实际情况调整
coord_points = points(:, 1:3);
normal_vectors = points(:, 4:6);
flags = Flag02;
%[interp_points, interp_normals] = uniformResamplePath(coord_points, normal_vectors, target_spacing);
[interp_points, interp_normals, interp_flags] = uniformResamplePath2(coord_points, normal_vectors, target_spacing, flags);
ResamplePath02 = [interp_points,interp_normals];


ResamplePath = [ResamplePath02;ResamplePath01;ResamplePath02(1,:)];

% %后续层
% %后续第一层0.2层厚
% ResamplePathNXT = ResamplePath(:,1:3)+ResamplePath(:,4:6)*0.25;
% ResamplePathNXT = [ResamplePathNXT,ResamplePath(:,4:6)];
% ResamplePath = [ResamplePath;ResamplePathNXT];

% 可视化结果
figure
hold on;
plot3(ResamplePath(:,1), ResamplePath(:,2), ...
      ResamplePath(:,3),'b-');
quiver3(ResamplePath(:,1), ResamplePath(:,2), ...
    ResamplePath(:,3), ResamplePath(:,4), ...
    ResamplePath(:,5), ResamplePath(:,6));
showNum = 4;
scatter3(ResamplePath(1:1+showNum,1),ResamplePath(1:1+showNum,2),ResamplePath(1:1+showNum,3),'blue','filled');
scatter3(ResamplePath(end-4:end,1),ResamplePath(end-showNum:end,2),ResamplePath(end-showNum:end,3),'red','filled');
%锐角倒角处理
smooth_ratio = 0.4;
%smoothed_path = smooth_acute_angles(ResamplePath, smooth_ratio);
smoothed_path = smooth_acute_angles_optimized(ResamplePath, smooth_ratio);
ResamplePath = smoothed_path;
interp_flags = ones(length(smoothed_path(:,1)),1);

figure
hold on;
plot3(ResamplePath(:,1), ResamplePath(:,2), ...
      ResamplePath(:,3),'k-',LineWidth=3);
quiver3(ResamplePath(:,1), ResamplePath(:,2), ...
    ResamplePath(:,3), ResamplePath(:,4), ...
    ResamplePath(:,5), ResamplePath(:,6));
showNum = 4;
scatter3(ResamplePath(1:1+showNum,1),ResamplePath(1:1+showNum,2),ResamplePath(1:1+showNum,3),'blue','filled');
scatter3(ResamplePath(end-4:end,1),ResamplePath(end-showNum:end,2),ResamplePath(end-showNum:end,3),'red','filled');
% 绘制世界坐标系
%plot_coordinate_frame(eye(3), [0;0;0], 5);


% 2. 重命名变量（核心步骤）
pathPoints = ResamplePath;        % 把old_var的值赋给新变量new_var
clear old_var;            % 可选：删除旧变量，避免工作区冗余

% 3. 保存改名后的新变量到本地
save('pathPoints.mat', 'pathPoints');  % 保存新变量new_var到本地文件

title('Surface1#2', 'FontSize', 14);
xlabel('x', 'FontSize', 12);
ylabel('y', 'FontSize', 12);
zlabel('z', 'FontSize', 12);
set(gcf, 'Color', 'white');
view(-150,45);
axis equal
axis off;

%% 3.2.路径偏移处理（手动处理，确保一次性标定完毕）============================
IP = '192.168.0.10';
port = 30003;
isNeedmarkTIP = 0;%★
if(isNeedmarkTIP)%重新标定
    % pos1
    isdone = input('请移动机械臂TCP到第一个尖点 (1-OK, 2-NG: ');
    if isdone == 1
        [pose1_current_m,~] = GetURPos(IP,port);
        save('pose1_current_m.mat','pose1_current_m');%保存路径文件
    else
        disp('位置获取失败，请重新执行！')
        return
    end
    % pos2
    isdone = input('请移动机械臂TCP到第二个尖点 (1-OK, 2-NG: ');
    if isdone == 1
        [pose2_current_m,~] = GetURPos(IP,port);
        save('pose2_current_m.mat','pose2_current_m');%保存路径文件
    else
        disp('位置获取失败，请重新执行！')
        return
    end

    % pos3
    isdone = input('请移动机械臂TCP到第三个尖点 (1-OK, 2-NG: ');
    if isdone == 1
        [pose3_current_m,~] = GetURPos(IP,port);
        save('pose3_current_m.mat','pose3_current_m');%保存路径文件
    else
        disp('位置获取失败，请重新执行！')
        return
    end
else%直接加载
    % LoadPose
    load("pose1_current_m.mat");
    load("pose2_current_m.mat");
    load("pose3_current_m.mat");
end

%% 路径生成
offset = 0.05;%★
%%% 3.3.偏移处理===============================================================
cad_markers_mm = Tips;%获取模型标记点位置
real_markers_m = [pose1_current_m(1:3)';pose2_current_m(1:3)';pose3_current_m(1:3)'];
real_markers_mm = real_markers_m.*1000;%M->mm
real_markers_mm(:,3) =real_markers_mm (:,3)+offset;
transformed_path = transformPathSimple(ResamplePath, cad_markers_mm, real_markers_mm);%坐标转换
plot3(transformed_path(:,1), transformed_path(:,2), ...
      transformed_path(:,3),'k-');
quiver3(transformed_path(:,1), transformed_path(:,2), ...
    transformed_path(:,3), transformed_path(:,4), ...
    transformed_path(:,5), transformed_path(:,6));
%%% 4.0.机械臂运动姿态生成======================================================
% UR路径姿态生成
method = 1;
pathData = transformed_path;
%%
pathData(:,4:6) = pathData(:,4:6)*-1;
if method == 1
    % 指定固定的全局X轴方向
    fixed_x_direction = [1, 0, 0];
    ur_waypoints = pathToURPoses_FixedX(pathData, fixed_x_direction);
    %ur_waypoints = pathToURPoses_FixedX2(pathData, fixed_x_direction);
    method_name = '固定X轴方向';
elseif method == 2
    ur_waypoints = pathToURPoses_PathDirectionX(pathData);
    method_name = '路径方向作为X轴';
else
    error('请选择1或2');
end

ur_path = ur_waypoints(1:end,:);
%可视化路径
scale = 2;
stepnum = 25;
visualize_frames(ur_path, scale,stepnum);
%%% 4.1.喷头路径干涉处理=======================================================
%%% 4.2.机械臂可执行文件生成 ====================================================
%修改姿态信息
UR_PathOffset = ur_path;
currentPos_XYZ_mm = pose1_current_m(1:3)*1000;%用于路径生成
HomePos_mm = currentPos_XYZ_mm+[0,0,20]';     %home点位当前点
RXYZ = pose1_current_m(4:6);     
%打印工艺设置
V = 0.55;              %移动速度 mm/s
Pressure = 115;      %供料气压 Kpa
%脚本生成
fileNameOR = ['URTest_SixAxis_Test_',MName,'_',num2str(offsetDistance)];
pathOnelayer = UR_PathOffset;
pathOnelayer(:,7) = interp_flags;
pathOnelayer(1,7) = 0;
%[URGcode] = generateURGcodeABS(pathOnelayer,HomePos_mm,currentPos_XYZ_mm,RXYZ,V,Pressure);
[URGcodeOR,URGcodeChunks] = generateURGcodeABSV3(pathOnelayer,HomePos_mm,currentPos_XYZ_mm,RXYZ,V,Pressure);

%%
for f = 1:length(URGcodeChunks)
    fileName = [fileNameOR,'_Index_',num2str(f)];
    URGcode = URGcodeChunks{f};
    %文件保存
    fid = fopen([fileName,'.script'], 'w');
    fprintf(fid, '%s', URGcode);
    fclose(fid);
    disp('URscript代码已生成');
end

%% 5.0.在线路径发送执行（路径较多的曲面进行）




%% Test测试区域

%% Function 依赖函数
function[pose_current_m,joint_current_rad] = GetURPos(IP,port)
    % 建立客户端:需要写入服务器IP地址和端口号
    client = tcpclient(IP, port);  % 使用新的tcpclient函数
    client.ByteOrder = 'big-endian';  % 设置为大端模式
    [pose_current_m,joint_current_rad] = InfoFromRobot(client);
    clear client;  % 清除客户端对象
    disp('机械臂位置已获取');
end

function transformed_path = transformPathSimple(path, cad_markers, real_markers)
    % path: N×6矩阵 [X,Y,Z,nx,ny,nz] - CAD模型中的路径点
    % cad_markers: 3×3矩阵 [P0; P1; P2] - CAD模型中的标记点
    % real_markers: 3×3矩阵 [P0_real; P1_real; P2_real] - 现实中的标记点
    
    % 步骤1: 计算CAD坐标系的基向量
    P0_cad = cad_markers(1,:);
    P1_cad = cad_markers(2,:);
    P2_cad = cad_markers(3,:);
    
    % X轴: P0->P1方向
    x_cad = (P1_cad - P0_cad)';
    x_cad = x_cad / norm(x_cad);
    
    % 临时向量: P0->P2
    temp_cad = (P2_cad - P0_cad)';
    
    % Z轴: 与X轴和临时向量垂直
    z_cad = cross(x_cad, temp_cad);
    z_cad = z_cad / norm(z_cad);
    
    % Y轴: 与X轴和Z轴垂直
    y_cad = cross(z_cad, x_cad);
    
    % CAD坐标系到世界坐标系的旋转矩阵
    R_cad = [x_cad, y_cad, z_cad];
    
    % 步骤2: 计算现实坐标系的基向量
    P0_real = real_markers(1,:);
    P1_real = real_markers(2,:);
    P2_real = real_markers(3,:);
    
    % X轴: P0_real->P1_real方向
    x_real = (P1_real - P0_real)';
    x_real = x_real / norm(x_real);
    
    % 临时向量: P0_real->P2_real
    temp_real = (P2_real - P0_real)';
    
    % Z轴: 与X轴和临时向量垂直
    z_real = cross(x_real, temp_real);
    z_real = z_real / norm(z_real);
    
    % Y轴: 与X轴和Z轴垂直
    y_real = cross(z_real, x_real);
    
    % 现实坐标系的旋转矩阵
    R_real = [x_real, y_real, z_real];
    
    % 步骤3: 计算变换矩阵
    % 从CAD坐标系到现实坐标系的旋转
    R = R_real / R_cad;
    
    % 平移变换: 确保P0点正确对应
    t = P0_real' - R * P0_cad';
    
    % 步骤4: 变换路径点
    num_points = size(path, 1);
    transformed_path = zeros(num_points, 6);
    
    for i = 1:num_points
        % 变换位置
        pos_cad = path(i, 1:3)';
        pos_real = R * pos_cad + t;
        
        % 变换法向量 (只旋转)
        normal_cad = path(i, 4:6)';
        normal_real = R * normal_cad;
        normal_real = normal_real / norm(normal_real);
        
        transformed_path(i, :) = [pos_real', normal_real'];
    end
    
    % 简单验证
    fprintf('变换完成，共处理 %d 个路径点\n', num_points);
    
    % 检查标记点变换精度
    transformed_P0 = (R * P0_cad' + t)';
    error_P0 = norm(transformed_P0 - P0_real);
    fprintf('P0点变换误差: %.3f mm\n', error_P0);
end

function [interp_points, interp_normals] = uniformResamplePath(points, normals, target_spacing)
% 对路径点进行等间距重采样并实现法向量连续过渡
% 输入参数：
%   points: N×3矩阵，XYZ坐标点
%   normals: N×3矩阵，法向量NXNYNZ
%   target_spacing: 目标间距
% 输出参数：
%   interp_points: 重采样后的坐标点
%   interp_normals: 重采样后的法向量

    % 参数检查
    if nargin < 3
        target_spacing = 1.0; % 默认间距
    end
    
    if size(points, 2) ~= 3 || size(normals, 2) ~= 3
        error('输入数据必须是3列坐标点和3列法向量');
    end
    
    % 预处理：移除重复点
    [points, normals] = removeDuplicatePoints(points, normals);
    
    % 计算累积弧长
    [cumulative_length, total_length] = computeCumulativeLength(points);
    
    % 如果总长度太小，直接返回原始数据
    if total_length < target_spacing
        warning('总路径长度小于目标间距，返回原始数据');
        interp_points = points;
        interp_normals = normals;
        return;
    end
    
    % 生成等间距的参数化点
    num_new_points = max(ceil(total_length / target_spacing) + 1, 2);
    uniform_params = linspace(0, total_length, num_new_points);
    
    % 对坐标点进行样条插值（使用pchip避免振荡）
    interp_points = zeros(num_new_points, 3);
    for i = 1:3
        % 确保插值参数在累积弧长范围内
        valid_params = uniform_params;
        valid_params = min(max(valid_params, cumulative_length(1)), cumulative_length(end));
        
        interp_points(:, i) = interp1(cumulative_length, points(:, i), valid_params, 'pchip');
    end
    
    % 对法向量进行球面线性插值(SLERP)以实现连续过渡
    interp_normals = slerpNormals(cumulative_length, normals, uniform_params);
    
end

function [interp_points, interp_normals, interp_flags] = uniformResamplePath2(points, normals, target_spacing, flags)
% 对路径点进行等间距重采样并实现法向量连续过渡，支持标志位插补
% 输入参数：
%   points: N×3矩阵，XYZ坐标点
%   normals: N×3矩阵，法向量NXNYNZ
%   target_spacing: 目标间距
%   flags: N×1向量，标志位（如叶节点标记等）
% 输出参数：
%   interp_points: 重采样后的坐标点
%   interp_normals: 重采样后的法向量
%   interp_flags: 重采样后的标志位

    % 参数检查
    if nargin < 3
        target_spacing = 1.0; % 默认间距
    end
    
    if size(points, 2) ~= 3 || size(normals, 2) ~= 3
        error('输入数据必须是3列坐标点和3列法向量');
    end
    
    % 检查是否有标志位输入
    has_flags = nargin >= 4 && ~isempty(flags);
    if has_flags && length(flags) ~= size(points, 1)
        error('标志位长度必须与点数一致');
    end
    
    % 预处理：移除重复点
    if has_flags
        [points, normals, flags] = removeDuplicatePointsWithFlags(points, normals, flags);
    else
        [points, normals] = removeDuplicatePoints(points, normals);
    end
    
    % 计算累积弧长
    [cumulative_length, total_length] = computeCumulativeLength(points);
    
    % 如果总长度太小，直接返回原始数据
    if total_length < target_spacing
        warning('总路径长度小于目标间距，返回原始数据');
        interp_points = points;
        interp_normals = normals;
        if has_flags
            interp_flags = flags;
        else
            interp_flags = [];
        end
        return;
    end
    
    % 生成等间距的参数化点
    num_new_points = max(ceil(total_length / target_spacing) + 1, 2);
    uniform_params = linspace(0, total_length, num_new_points);
    
    % 对坐标点进行样条插值（使用pchip避免振荡）
    interp_points = zeros(num_new_points, 3);
    for i = 1:3
        % 确保插值参数在累积弧长范围内
        valid_params = uniform_params;
        valid_params = min(max(valid_params, cumulative_length(1)), cumulative_length(end));
        
        interp_points(:, i) = interp1(cumulative_length, points(:, i), valid_params, 'pchip');
    end
    
    % 对法向量进行球面线性插值(SLERP)以实现连续过渡
    interp_normals = slerpNormals(cumulative_length, normals, uniform_params);
    
    % 对标志位进行插值（使用最近邻或线性插值）
    if has_flags
        interp_flags = interpolateFlags(cumulative_length, flags, uniform_params);
    else
        interp_flags = [];
    end
    
end

function [points, normals, flags] = removeDuplicatePointsWithFlags(points, normals, flags)
% 移除重复点，同时处理标志位
    [~, unique_indices] = unique(points, 'rows', 'stable');
    points = points(unique_indices, :);
    normals = normals(unique_indices, :);
    flags = flags(unique_indices, :);
end

function interp_flags = interpolateFlags(cumulative_length, flags, uniform_params)
% 对标志位进行插值
% 对于离散的标志位，使用最近邻插值
    interp_flags = zeros(length(uniform_params), 1);
    
    for i = 1:length(uniform_params)
        % 找到最近的原始点
        [~, nearest_idx] = min(abs(cumulative_length - uniform_params(i)));
        interp_flags(i) = flags(nearest_idx);
    end
    
    % 或者使用取整的线性插值（对于数值型标志位）
    % interp_flags = round(interp1(cumulative_length, flags, uniform_params, 'linear', 'extrap'));
end

function [cumulative_length, total_length] = computeCumulativeLength(points)
% 计算累积弧长
    diff_points = diff(points);
    segment_lengths = sqrt(sum(diff_points.^2, 2));
    cumulative_length = [0; cumsum(segment_lengths)];
    total_length = cumulative_length(end);
end

function interp_normals = slerpNormals(cumulative_length, normals, uniform_params)
% 对法向量进行球面线性插值
    num_new_points = length(uniform_params);
    interp_normals = zeros(num_new_points, 3);
    
    for i = 1:num_new_points
        param = uniform_params(i);
        
        % 找到包围当前参数的区间
        idx = find(cumulative_length <= param, 1, 'last');
        
        if idx == length(cumulative_length)
            % 如果是最后一个点
            interp_normals(i, :) = normals(end, :);
        else
            % 计算插值比例
            t = (param - cumulative_length(idx)) / (cumulative_length(idx+1) - cumulative_length(idx));
            
            % 对法向量进行球面线性插值
            n1 = normals(idx, :);
            n2 = normals(idx+1, :);
            
            % 确保法向量单位化
            n1 = n1 / norm(n1);
            n2 = n2 / norm(n2);
            
            % 计算夹角
            dot_product = dot(n1, n2);
            dot_product = max(min(dot_product, 1), -1); % 防止数值误差
            
            theta = acos(dot_product);
            
            if abs(theta) < 1e-10
                % 如果夹角很小，使用线性插值
                interp_normals(i, :) = (1-t)*n1 + t*n2;
            else
                % SLERP公式
                interp_normals(i, :) = (sin((1-t)*theta)/sin(theta))*n1 + (sin(t*theta)/sin(theta))*n2;
            end
            
            % 单位化结果
            interp_normals(i, :) = interp_normals(i, :) / norm(interp_normals(i, :));
        end
    end
end

function [points, normals] = removeDuplicatePoints(points, normals)
% 移除重复点（原始版本）
    [~, unique_indices] = unique(points, 'rows', 'stable');
    points = points(unique_indices, :);
    normals = normals(unique_indices, :);
end

function [points_clean, normals_clean] = removeDuplicatePoints2(points, normals)
% 移除重复的点
    [~, unique_indices] = unique(points, 'rows', 'stable');
    points_clean = points(unique_indices, :);
    normals_clean = normals(unique_indices, :);
    
    if size(points_clean, 1) < size(points, 1)
        fprintf('移除了 %d 个重复点\n', size(points, 1) - size(points_clean, 1));
    end
end

function [cumulative_length, total_length] = computeCumulativeLength2(points)
% 计算累积弧长，确保唯一性
    diff_points = diff(points);
    segment_lengths = sqrt(sum(diff_points.^2, 2));
    
    % 检查并处理零长度段
    zero_length_indices = segment_lengths < 1e-10;
    if any(zero_length_indices)
        fprintf('发现 %d 个零长度段，已处理\n', sum(zero_length_indices));
        segment_lengths(zero_length_indices) = 1e-10; % 给一个很小的值
    end
    
    cumulative_length = [0; cumsum(segment_lengths)];
    total_length = cumulative_length(end);
    
    % 确保累积弧长严格递增
    if any(diff(cumulative_length) <= 0)
        % 如果仍有问题，强制使其递增
        cumulative_length = (0:length(cumulative_length)-1)' * (total_length / (length(cumulative_length)-1));
    end
end

function interp_normals = slerpNormals2(original_params, normals, new_params)
% 使用球面线性插值对法向量进行插值
    num_new_points = length(new_params);
    interp_normals = zeros(num_new_points, 3);
    
    % 归一化输入法向量
    original_normals_normalized = normals ./ vecnorm(normals, 2, 2);
    
    for i = 1:num_new_points
        param = new_params(i);
        
        % 找到相邻的原始点
        idx = find(original_params <= param, 1, 'last');
        
        if isempty(idx)
            interp_normals(i, :) = original_normals_normalized(1, :);
        elseif idx == length(original_params)
            interp_normals(i, :) = original_normals_normalized(end, :);
        else
            % 计算插值权重
            t = (param - original_params(idx)) / (original_params(idx+1) - original_params(idx));
            t = max(0, min(1, t)); % 限制在[0,1]范围内
            
            % 获取相邻法向量
            n1 = original_normals_normalized(idx, :);
            n2 = original_normals_normalized(idx+1, :);
            
            % 球面线性插值
            interp_normals(i, :) = slerp(n1, n2, t);
        end
    end
end

function result = slerp(v0, v1, t)
% 球面线性插值
    % 计算点积和夹角
    dot_product = dot(v0, v1);
    dot_product = max(min(dot_product, 1), -1); % 防止数值误差
    
    theta = acos(dot_product);
    
    if abs(theta) < 1e-10
        % 如果夹角很小，使用线性插值
        result = (1-t)*v0 + t*v1;
    else
        % 球面线性插值公式
        result = (sin((1-t)*theta) * v0 + sin(t*theta) * v1) / sin(theta);
    end
    
    % 归一化结果
    if norm(result) > 0
        result = result / norm(result);
    else
        result = v0; % 退化为第一个向量
    end
end

function visualizeResults(original_points, original_normals, interp_points, interp_normals)
% 可视化原始数据和插值结果
    figure;
    
    % 绘制原始路径点
    subplot(2,2,1);
    plot3(original_points(:,1), original_points(:,2), original_points(:,3), 'ro-', 'LineWidth', 2, 'MarkerSize', 6);
    hold on;
    plot3(interp_points(:,1), interp_points(:,2), interp_points(:,3), 'b.-', 'MarkerSize', 10);
    legend('原始点', '重采样点', 'Location', 'best');
    title('路径点对比');
    grid on; axis equal;
    xlabel('X'); ylabel('Y'); zlabel('Z');
    
    % 绘制原始法向量
    subplot(2,2,2);
    plot3(original_points(:,1), original_points(:,2), original_points(:,3), 'r.-');
    hold on;
    quiver3(original_points(:,1), original_points(:,2), original_points(:,3), ...
            original_normals(:,1), original_normals(:,2), original_normals(:,3), 0.3, 'r');
    title('原始法向量');
    grid on; axis equal;
    xlabel('X'); ylabel('Y'); zlabel('Z');
    
    % 绘制插值法向量
    subplot(2,2,3);
    plot3(interp_points(:,1), interp_points(:,2), interp_points(:,3), 'b.-');
    hold on;
    quiver3(interp_points(:,1), interp_points(:,2), interp_points(:,3), ...
            interp_normals(:,1), interp_normals(:,2), interp_normals(:,3), 0.3, 'b');
    title('插值法向量');
    grid on; axis equal;
    xlabel('X'); ylabel('Y'); zlabel('Z');
    
    % 绘制法向量连续性检查
    subplot(2,2,4);
    dot_products = dot(interp_normals(1:end-1,:), interp_normals(2:end,:), 2);
    angles = acosd(min(max(dot_products, -1), 1)); % 转换为角度
    plot(angles, 'b.-');
    title('相邻法向量夹角(度)');
    xlabel('点索引');
    ylabel('夹角(度)');
    grid on;
    
    fprintf('法向量连续性统计:\n');
    fprintf('最大夹角: %.4f 度\n', max(angles));
    fprintf('最小夹角: %.4f 度\n', min(angles));
    fprintf('平均夹角: %.4f 度\n', mean(angles));
end

% 四元数转换函数
function[Q] =  path_to_quaternion(pathNormal)
Q = [];
    for i = 1:size(pathNormal, 1)
        normal = pathNormal(i, :);
        % 计算四元数（仅Z轴对齐法向量）
        q = zvector_to_quaternion(normal);
        Q = [Q;q];
    end
end

function q = zvector_to_quaternion(normal)
% 仅使用Z轴向量计算四元数，保持X和Y轴尽可能接近默认姿态
    % 归一化Z轴
    normal = normal;
    z_axis = normal(:)' / norm(normal);
    
    % 默认X轴方向（世界坐标系X轴）
    default_x = [1, 0, 0];
    
    % 计算实际X轴（尽可能接近默认方向）
    if abs(dot(z_axis, default_x)) < 0.9999
        % 如果Z轴不平行于默认X轴
        x_axis = default_x - dot(default_x, z_axis) * z_axis;
        x_axis = x_axis / norm(x_axis);
    else
        % 如果Z轴几乎平行于默认X轴，使用Y轴作为基准
        default_y = [0, 1, 0];
        x_axis = default_y - dot(default_y, z_axis) * z_axis;
        x_axis = x_axis / norm(x_axis);
    end
    
    % 计算Y轴
    y_axis = cross(z_axis, x_axis);
    
    % 构建旋转矩阵
    R = [x_axis', y_axis', z_axis'];
    
    % 旋转矩阵转四元数
    trace = R(1,1) + R(2,2) + R(3,3);
    
    if trace > 0
        S = sqrt(trace + 1.0) * 2;
        qw = 0.25 * S;
        qx = (R(3,2) - R(2,3)) / S;
        qy = (R(1,3) - R(3,1)) / S;
        qz = (R(2,1) - R(1,2)) / S;
    elseif (R(1,1) > R(2,2)) && (R(1,1) > R(3,3))
        S = sqrt(1.0 + R(1,1) - R(2,2) - R(3,3)) * 2;
        qw = (R(3,2) - R(2,3)) / S;
        qx = 0.25 * S;
        qy = (R(1,2) + R(2,1)) / S;
        qz = (R(1,3) + R(3,1)) / S;
    elseif R(2,2) > R(3,3)
        S = sqrt(1.0 + R(2,2) - R(1,1) - R(3,3)) * 2;
        qw = (R(1,3) - R(3,1)) / S;
        qx = (R(1,2) + R(2,1)) / S;
        qy = 0.25 * S;
        qz = (R(2,3) + R(3,2)) / S;
    else
        S = sqrt(1.0 + R(3,3) - R(1,1) - R(2,2)) * 2;
        qw = (R(2,1) - R(1,2)) / S;
        qx = (R(1,3) + R(3,1)) / S;
        qy = (R(2,3) + R(3,2)) / S;
        qz = 0.25 * S;
    end
    q = [qw, qx, qy, qz];
end

function visualize_path(path_points,Name)
% 创建图形窗口
fig = figure('Name', Name, 'NumberTitle', 'off', ...
    'Position', [100, 100, 800, 600], 'Color', 'white');
movegui(fig, 'center');

% 创建3D坐标系
ax = axes('Parent', fig);
hold(ax, 'on');
grid(ax, 'on');
axis(ax, 'equal');
xlabel(ax, 'X (mm)');
ylabel(ax, 'Y (mm)');
zlabel(ax, 'Z (mm)');
title(ax, '机器人路径与工具方向验证');
view(ax, 3);
rotate3d(ax, 'on');

% 提取位置和法向量
positions = path_points(:, 1:3);
normals = path_points(:, 4:6);

% 计算箭头缩放比例
max_dim = max(max(positions) - min(positions));
arrow_scale = max_dim * 0.15;

% 绘制路径线
plot3(ax, positions(:,1), positions(:,2), positions(:,3), ...
    'k-o', 'LineWidth', 1.5, 'MarkerSize', 6, 'MarkerFaceColor', 'b');
scatter3(0,0,0,"red","filled");
% 标记起点和终点
text(positions(1,1), positions(1,2), positions(1,3), '起点', ...
    'Color', 'blue', 'FontWeight', 'bold');
text(positions(end,1), positions(end,2), positions(end,3), '终点', ...
    'Color', 'blue', 'FontWeight', 'bold');

% 绘制每个点的工具方向
for i = 1:size(path_points, 1)
    pos = positions(i,:);
    normal = normals(i,:);
    
    % 计算四元数和旋转矩阵
    q = zvector_to_quaternion(normal);
    R = quat2rotm(q);
    
    % 绘制Z轴（法向量方向，蓝色）
    quiver3(ax, pos(1), pos(2), pos(3), ...
            normal(1), normal(2), normal(3), arrow_scale, ...
            'b', 'LineWidth', 2, 'MaxHeadSize', 0.3);
    
    % 绘制X轴（红色）
    x_dir = R(:,1)';
    quiver3(ax, pos(1), pos(2), pos(3), ...
            x_dir(1), x_dir(2), x_dir(3), arrow_scale*0.8, ...
            'r', 'LineWidth', 1.5, 'MaxHeadSize', 0.2);
    
    % 绘制Y轴（绿色）
    y_dir = R(:,2)';
    quiver3(ax, pos(1), pos(2), pos(3), ...
            y_dir(1), y_dir(2), y_dir(3), arrow_scale*0.8, ...
            'g', 'LineWidth', 1.5, 'MaxHeadSize', 0.2);
    
    % 显示点编号
    text(pos(1), pos(2), pos(3), sprintf(' %d', i), ...
         'Color', 'black', 'FontSize', 8);
end

% 添加图例
legend(ax, {'路径轨迹', '机械臂运动起始点','Z轴(法向)', 'X轴', 'Y轴'}, 'Location', 'best');

% 设置视角
view(ax, 30, 30);
rotate3d(ax, 'on');

% 添加标题和说明
annotation(fig, 'textbox', [0.05, 0.9, 0.9, 0.1], ...
    'String', 'ABB路径可视化 - 验证Z轴(红色)是否与输入法向量对齐', ...
    'EdgeColor', 'none', 'HorizontalAlignment', 'center', ...
    'FontWeight', 'bold');
end

function [orderALLPoints_with_normals] = pathWithNormal(pathSptOnelayerSurfX,Base,sigma)
    pathSptPntsX = pathSptOnelayerSurfX(:,1:3);
    X = Base.vertices;
    F = Base.faces;
    face_normals = computeFaceNormals(X, F); % V 是顶点，F 是面片
    point_normals = assignPointNormals(pathSptPntsX, X, F, face_normals);

%     sigma = 1.5;
    smoothed_normals = builtinGaussianSmooth(point_normals, sigma);
    orderALLPoints_with_normals = [pathSptPntsX, smoothed_normals];
end

function smoothed_normals = builtinGaussianSmooth(normals, sigma)
    % 使用MATLAB内置的imgaussfilt（需要将法向量视为图像）
    
    N = size(normals, 1);
    
    % 分别对法向量的三个分量进行高斯滤波
    nx_smoothed = imgaussfilt(normals(:,1), sigma, 'FilterSize', min(11, N));
    ny_smoothed = imgaussfilt(normals(:,2), sigma, 'FilterSize', min(11, N));
    nz_smoothed = imgaussfilt(normals(:,3), sigma, 'FilterSize', min(11, N));
    
    % 重新归一化
    smoothed_normals = normals;
    for i = 1:N
        smoothed_vector = [nx_smoothed(i), ny_smoothed(i), nz_smoothed(i)];
        norm_val = norm(smoothed_vector);
        if norm_val > eps
            smoothed_normals(i, 1:3) = smoothed_vector / norm_val;
        end
    end
end

function point_normals = assignPointNormals(points, vertices, faces, face_normals)
    % 为路径点分配法向（点完全在曲面上的优化版本）
    point_normals = zeros(size(points, 1), 3);
    
    % 预计算每个面的顶点和质心
    num_faces = size(faces, 1);
    face_vertices = cell(num_faces, 1);
    centroids = zeros(num_faces, 3);
    
    for i = 1:num_faces
        face_vertices{i} = vertices(faces(i, :), :);
        centroids(i, :) = mean(face_vertices{i}, 1);
    end
    
    % 为每个点快速找到所属面
    for i = 1:size(points, 1)
        point = points(i, :);
        
        % 快速找到包含该点的面（由于点保证在面上，通常很快找到）
        containing_face = findContainingFaceFast(point, vertices, faces, face_vertices, centroids);
        
        if containing_face > 0
            point_normals(i, :) = face_normals(containing_face, :);
        else
            % 备用方案：使用最近面（理论上不应该发生）
            [~, closest_face] = min(sum((centroids - point).^2, 2));
            point_normals(i, :) = face_normals(closest_face, :);
        end
    end
end

function containing_face = findContainingFaceFast(point, vertices, faces, face_vertices, centroids)
    % 快速找到包含点的面（优化版本）
    
    % 首先检查最近的面（大概率包含该点）
    [~, closest_faces] = sort(sum((centroids - point).^2, 2));
    
    % 按距离顺序检查前几个面
    max_checks = min(10, size(faces, 1)); % 最多检查10个最近的面
    
    for idx = 1:max_checks
        face_idx = closest_faces(idx);
        v1 = face_vertices{face_idx}(1, :);
        v2 = face_vertices{face_idx}(2, :);
        v3 = face_vertices{face_idx}(3, :);
        
        if isPointInTriangleFast(point, v1, v2, v3)
            containing_face = face_idx;
            return;
        end
    end
    
    % 如果前几个面没找到，继续检查其他面
    for idx = max_checks + 1:length(closest_faces)
        face_idx = closest_faces(idx);
        v1 = face_vertices{face_idx}(1, :);
        v2 = face_vertices{face_idx}(2, :);
        v3 = face_vertices{face_idx}(3, :);
        
        if isPointInTriangleFast(point, v1, v2, v3)
            containing_face = face_idx;
            return;
        end
    end
    
    containing_face = 0; % 没找到（理论上不应该发生）
end

function inside = isPointInTriangleFast(point, v1, v2, v3)
    % 快速点在三角形内判断（使用重心坐标法，优化版本）
    
    % 向量计算
    v0 = v3 - v1;
    v1_vec = v2 - v1;
    v2_vec = point - v1;
    
    % 点积计算
    dot00 = v0(1)*v0(1) + v0(2)*v0(2) + v0(3)*v0(3);
    dot01 = v0(1)*v1_vec(1) + v0(2)*v1_vec(2) + v0(3)*v1_vec(3);
    dot02 = v0(1)*v2_vec(1) + v0(2)*v2_vec(2) + v0(3)*v2_vec(3);
    dot11 = v1_vec(1)*v1_vec(1) + v1_vec(2)*v1_vec(2) + v1_vec(3)*v1_vec(3);
    dot12 = v1_vec(1)*v2_vec(1) + v1_vec(2)*v2_vec(2) + v1_vec(3)*v2_vec(3);
    
    % 计算重心坐标
    invDenom = 1 / (dot00 * dot11 - dot01 * dot01);
    u = (dot11 * dot02 - dot01 * dot12) * invDenom;
    v = (dot00 * dot12 - dot01 * dot02) * invDenom;
    
    % 判断点是否在三角形内（使用容差）
    inside = (u >= -1e-10) && (v >= -1e-10) && (u + v <= 1 + 1e-10);
end

function normals = computeFaceNormals(vertices, faces)
    % 计算每个三角形面片的法向
    normals = zeros(size(faces, 1), 3);
    for i = 1:size(faces, 1)
        v1 = vertices(faces(i, 1), :);
        v2 = vertices(faces(i, 2), :);
        v3 = vertices(faces(i, 3), :);
        normals(i, :) = cross(v2 - v1, v3 - v1);
        normals(i, :) = normals(i, :) / norm(normals(i, :)); % 单位化
    end
end

function [pathSptOnelayerSurfX] = pathProjection(pathSptOnelayerX, Base,dir)
    Points = pathSptOnelayerX(:,1:3);
    vertices = Base.vertices;
    faces = Base.faces;
%     dir   = [0 0 -10];         % ray's direction
    vert1 = vertices(faces(:,1),:);
    vert2 = vertices(faces(:,2),:);
    vert3 = vertices(faces(:,3),:);
    SurfacePoints = [];
    %进行路径投影
    for j=1:length(Points)
        orig = Points(j,:);
        [intersect,t,u,v,xcoor] = TriangleRayIntersection(orig, dir, vert1, vert2, vert3);
        k = find(intersect);
        if (k>0)
            SurfacePoints = [SurfacePoints;xcoor(k(1),:)];
        else
            %SurfacePoints = SurfacePoints;
        end  
    end
    pathSptOnelayerSurfX = [SurfacePoints,pathSptOnelayerX(:,4)];%风险项确保所有路径点都要在曲面上
    
%     figure(fig3);
%     hold on
%     points_0 = pathSptOnelayerSurfX(pathSptOnelayerSurfX(:,4)==0,1:3);
%     points_1 = pathSptOnelayerSurfX(pathSptOnelayerSurfX(:,4)==1,1:3);
%     plot3(SurfacePoints(:,1),SurfacePoints(:,2),SurfacePoints(:,3),'b-','DisplayName', 'Support Layer X', 'LineWidth', 2);
%     scatter3(points_0(:,1), points_0(:,2), points_0(:,3), 50, 'r', 'filled', 'DisplayName', 'Flag=0');
%     scatter3(points_1(:,1), points_1(:,2), points_1(:,3), 50, 'b', 'filled', 'DisplayName', 'Flag=1');
%     lgd = legend();
%     lgd.FontSize = 12;
%     lgd.TextColor = 'blue';
%     lgd.EdgeColor = 'red'; % 边框颜色
%     lgd.Color = [0.9, 0.9, 0.9]; % 背景色，使用RGB向量
%     hold off
end

function [pathSptOnelayerSurfX] = pathProjection1(pathSptOnelayerX, Base,dir)
    Points = pathSptOnelayerX(:,1:3);
    vertices = Base.vertices;
    faces = Base.faces;
%     dir   = [0 0 -10];         % ray's direction
    vert1 = vertices(faces(:,1),:);
    vert2 = vertices(faces(:,2),:);
    vert3 = vertices(faces(:,3),:);
    SurfacePoints = [];
    %进行路径投影
    for j=1:length(Points)
        orig = Points(j,:);
        [intersect,t,u,v,xcoor] = TriangleRayIntersection(orig, dir, vert1, vert2, vert3);
        k = find(intersect);
        if (k>0)
            SurfacePoints = [SurfacePoints;xcoor(k(1),:)];
        else
            %SurfacePoints = SurfacePoints;
        end  
    end
    pathSptOnelayerSurfX = [SurfacePoints,pathSptOnelayerX(:,4)];%风险项确保所有路径点都要在曲面上
    
%     figure(fig3);
%     hold on
%     points_0 = pathSptOnelayerSurfX(pathSptOnelayerSurfX(:,4)==0,1:3);
%     points_1 = pathSptOnelayerSurfX(pathSptOnelayerSurfX(:,4)==1,1:3);
%     plot3(SurfacePoints(:,1),SurfacePoints(:,2),SurfacePoints(:,3),'b-','DisplayName', 'Support Layer X', 'LineWidth', 2);
%     scatter3(points_0(:,1), points_0(:,2), points_0(:,3), 50, 'r', 'filled', 'DisplayName', 'Flag=0');
%     scatter3(points_1(:,1), points_1(:,2), points_1(:,3), 50, 'b', 'filled', 'DisplayName', 'Flag=1');
%     lgd = legend();
%     lgd.FontSize = 12;
%     lgd.TextColor = 'blue';
%     lgd.EdgeColor = 'red'; % 边框颜色
%     lgd.Color = [0.9, 0.9, 0.9]; % 背景色，使用RGB向量
%     hold off
end

function processed_array = processZeroXYPoints(array, epsilon)
    % 处理数组中XY坐标同时为0的点，避免歧义
    % 输入：
    %   array: N×3的数组，前三列为XYZ坐标
    %   epsilon: 接近0的小值（可选，默认1e-10）
    % 输出：
    %   processed_array: 处理后的数组
    
    if nargin < 2
        epsilon = 1e-10; % 默认接近0的值
    end
    
    if size(array, 2) ~= 3
        error('输入数组必须是N×3的数组');
    end
    
    % 复制原数组
    processed_array = array;
    
    % 找出XY坐标同时为0的点
    zero_xy_mask = (array(:, 1) == 0) & (array(:, 2) == 0);
    
    if any(zero_xy_mask)
        fprintf('找到 %d 个XY坐标为(0,0)的点，正在进行处理...\n', sum(zero_xy_mask));
        
        % 为这些点分配一个小的随机偏移量
        num_zero_points = sum(zero_xy_mask);
        
        % 方法1：随机小偏移（推荐）
        random_offset = (rand(num_zero_points, 2) - 0.5) * epsilon;
        processed_array(zero_xy_mask, 1:2) = random_offset;
        
        % 方法2：固定小偏移（可选）
        % processed_array(zero_xy_mask, 1) = epsilon;
        % processed_array(zero_xy_mask, 2) = epsilon;
        
        % 方法3：根据索引生成不同的小偏移（避免重复）
        % indices = find(zero_xy_mask);
        % angle = (0:num_zero_points-1)' * (2*pi/num_zero_points);
        % offset = epsilon * 0.5;
        % processed_array(zero_xy_mask, 1) = offset * cos(angle);
        % processed_array(zero_xy_mask, 2) = offset * sin(angle);
    else
        fprintf('没有找到XY坐标为(0,0)的点\n');
    end
end

function [pathOut] = pathMoveAndInterp(path,vector,step_size)
    % 平移
    path(:,1:3) = path(:,1:3)+vector;
    % 离散化
    pathOut = interpolatePathWithFlag(path, step_size);
    epsilon = 10e-8;
    pathOut2 = pathOut(:,1:3);
    pathOut2 = processZeroXYPoints(pathOut2, epsilon);%排除射线投影bug
    pathOut(:,1:3) = pathOut2;
end

function interpolated_path = interpolatePathWithFlag(original_path, step_size)
    % 检查输入参数
    if nargin < 2
        step_size = 0.1; % 默认步长为0.1单位
    end
    
    if size(original_path, 2) ~= 4
        error('输入路径必须是N×4的数组，前三列为XYZ坐标，第四列为标志位');
    end
    
    n = size(original_path, 1);
    if n < 2
        interpolated_path = original_path;
        return;
    end
    
    % 计算所有相邻点之间的距离
    distances = sqrt(sum(diff(original_path(:, 1:3)).^2, 2));
    
    % 预分配内存（估计最大可能大小）
    max_possible_points = n + sum(ceil(distances / step_size));
    interpolated_path = zeros(max_possible_points, 4);
    current_index = 1;
    
    % 添加第一个点
    interpolated_path(current_index, :) = original_path(1, :);
    current_index = current_index + 1;
    
    % 遍历每一段路径
    for i = 1:(n-1)
        % 获取当前段起点和终点
        start_point = original_path(i, 1:3);
        end_point = original_path(i+1, 1:3);
        start_flag = original_path(i, 4);
        end_flag = original_path(i+1, 4);
        current_distance = distances(i);
        
        % 确定当前段的标志位规则
        if start_flag == 0 && end_flag == 1
            segment_flag = 1; % 从0到1：所有插值点标志位为1
        elseif start_flag == 1 && end_flag == 0
            segment_flag = 0; % 从1到0：所有插值点标志位为0
        else
            segment_flag = start_flag; % 其他情况保持相同的标志位
        end
        
        % 如果距离大于步长，进行插值；否则保持原有点
        if current_distance > step_size
            % 计算需要插入的点数（至少插入1个点）
            num_insertions = max(1, floor(current_distance / step_size));
            
            % 生成插值参数（不包括起点，包括终点）
            t = linspace(0, 1, num_insertions + 1);
            t = t(2:end)'; % 去掉起点
            
            % 向量化计算插值点
            interpolated_points = start_point + t * (end_point - start_point);
            
            % 添加标志位
            flags = segment_flag * ones(num_insertions, 1);
            interpolated_segment = [interpolated_points, flags];
            
            % 将插值点添加到结果中
            num_new_points = size(interpolated_segment, 1);
            interpolated_path(current_index:current_index+num_new_points-1, :) = interpolated_segment;
            current_index = current_index + num_new_points;
        else
            % 距离小于等于步长，不插入新点，直接使用终点
            % （后续会添加终点）
        end
        
        % 添加当前段的终点
        interpolated_path(current_index, :) = original_path(i+1, :);
        current_index = current_index + 1;
    end
    
    % 裁剪到实际大小
    interpolated_path = interpolated_path(1:current_index-1, :);
    
    % 移除过于接近的连续重复点（保持标志位不同的点）
    interpolated_path = removeClosePoints(interpolated_path, step_size * 0.1);
end

function cleaned_path = removeClosePoints(path, min_distance)
    % 移除距离过近的连续点，但保持标志位变化的点
    if size(path, 1) < 2
        cleaned_path = path;
        return;
    end
    
    % 计算连续点之间的距离
    distances = sqrt(sum(diff(path(:, 1:3)).^2, 2));
    
    % 找到需要保留的点的索引
    keep_mask = true(size(path, 1), 1);
    
    for i = 2:size(path, 1)
        % 如果距离太小且标志位相同，标记为需要移除
        if distances(i-1) < min_distance && path(i, 4) == path(i-1, 4)
            keep_mask(i) = false;
        end
    end
    
    cleaned_path = path(keep_mask, :);
end

function visualize_framesRPY(ur_waypoints, scale,steps)
% 可视化转换后的工具坐标系
%
% 输入参数:
%   ur_waypoints - N×6矩阵，[X, Y, Z, Rx, Ry, Rz]
%   scale - (可选) 坐标系轴的长度，默认为0.05

    if nargin < 2
        scale = 3;
    end
    
    figure;
    hold on;
    grid on;
    axis equal;
    xlabel('X');
    ylabel('Y');
    zlabel('Z');
    title('UR路径点工具坐标系可视化');
    
    % 颜色定义：X轴-红色，Y轴-绿色，Z轴-蓝色
    colors = ['r', 'g', 'b'];
    
    for i = 1:steps:size(ur_waypoints, 1)
        % 提取位置和欧拉角
        pos = ur_waypoints(i, 1:3);
        rpy = ur_waypoints(i, 4:6);
        
        % 从RPY角重建旋转矩阵
        Rx = [1, 0, 0; 0, cos(rpy(1)), -sin(rpy(1)); 0, sin(rpy(1)), cos(rpy(1))];
        Ry = [cos(rpy(2)), 0, sin(rpy(2)); 0, 1, 0; -sin(rpy(2)), 0, cos(rpy(2))];
        Rz = [cos(rpy(3)), -sin(rpy(3)), 0; sin(rpy(3)), cos(rpy(3)), 0; 0, 0, 1];
        R = Rz * Ry * Rx;
        
        % 绘制坐标系
        for axis_idx = 1:3
            axis_direction = R(:, axis_idx)' * scale;
            quiver3(pos(1), pos(2), pos(3), ...
                    axis_direction(1), axis_direction(2), axis_direction(3), ...
                    'Color', colors(axis_idx), 'LineWidth', 1, 'MaxHeadSize', 1);
        end
        
        % 绘制位置点
        plot3(pos(1), pos(2), pos(3), 'ko', 'MarkerSize', 2, 'MarkerFaceColor', 'k');
    end

    plot3(ur_waypoints(:,1), ur_waypoints(:,2), ur_waypoints(:,3), 'k-');
    legend('X轴', 'Y轴', 'Z轴', '位置点');
    hold off;
end

function visualize_frames(ur_waypoints, scale, steps)
% 可视化转换后的工具坐标系
%
% 输入参数:
%   ur_waypoints - N×6矩阵，[X, Y, Z, Rx, Ry, Rz]
%                 Rx,Ry,Rz可以是欧拉角(默认)或旋转向量
%   scale - (可选) 坐标系轴的长度，默认为3
%   steps - (可选) 绘制间隔，默认为1

    if nargin < 2
        scale = 3;
    end
    if nargin < 3
        steps = 1;
    end
    
    figure;
    hold on;
    grid on;
    axis equal;
    xlabel('X');
    ylabel('Y');
    zlabel('Z');
    title('UR路径点工具坐标系可视化');
    
    % 颜色定义：X轴-红色，Y轴-绿色，Z轴-蓝色
    colors = ['r', 'g', 'b'];
    
    for i = 1:steps:size(ur_waypoints, 1)
        % 提取位置和旋转向量
        pos = ur_waypoints(i, 1:3);
        rot_vec = ur_waypoints(i, 4:6);
        
        % 从旋转向量计算旋转矩阵
        R = rotationVectorToMatrix(rot_vec);
        
        % 绘制坐标系
        for axis_idx = 1:3
            axis_direction = R(:, axis_idx)' * scale;
            quiver3(pos(1), pos(2), pos(3), ...
                    axis_direction(1), axis_direction(2), axis_direction(3), ...
                    'Color', colors(axis_idx), 'LineWidth', 1, 'MaxHeadSize', 1);
        end
        
        % 绘制位置点
        plot3(pos(1), pos(2), pos(3), 'ko', 'MarkerSize', 2, 'MarkerFaceColor', 'k');
        
        % 显示序号
        text(pos(1), pos(2), pos(3), num2str(i), 'FontSize', 8);
    end

    % 绘制路径连线
    plot3(ur_waypoints(:,1), ur_waypoints(:,2), ur_waypoints(:,3), 'k-', 'LineWidth', 0.5);
    
    legend('X轴', 'Y轴', 'Z轴', '位置点', 'Location', 'best');
    hold off;
end

function R = rotationVectorToMatrix(rot_vec)
% 将旋转向量转换为旋转矩阵
% 使用罗德里格斯公式

    theta = norm(rot_vec);
    if theta < eps
        R = eye(3);
    else
        k = rot_vec / theta;  % 单位旋转轴
        K = [0, -k(3), k(2); 
             k(3), 0, -k(1);
             -k(2), k(1), 0]; % 叉积矩阵
        
        R = eye(3) + sin(theta) * K + (1 - cos(theta)) * (K * K);
    end
end

% 使用可视化函数
% visualize_frames(ur_path);

% 固定X轴方向版本
function ur_poses = pathToURPoses_FixedX(pathData, fixed_x_direction)
    numPoints = size(pathData, 1);
    ur_poses = zeros(numPoints, 6);
    fixed_x_direction = fixed_x_direction / norm(fixed_x_direction);
    
    for i = 1:numPoints
        position = pathData(i, 1:3);
        normal = pathData(i, 4:6);
        z_axis = normal / norm(normal);
        
        y_axis_candidate = cross(z_axis, fixed_x_direction);
        
        if norm(y_axis_candidate) < 1e-5
            if abs(z_axis(3)) > 0.9
                backup_dir = [0, 1, 0];
            else
                backup_dir = [0, 0, 1];
            end
            proj_backup_on_z = dot(backup_dir, z_axis) * z_axis;
            y_axis_candidate = backup_dir - proj_backup_on_z;
        end
        
        y_axis = y_axis_candidate / norm(y_axis_candidate);
        x_axis = cross(y_axis, z_axis);
        x_axis = x_axis / norm(x_axis);
        
        R = [x_axis', y_axis', z_axis'];
        axang = rotm2axang(R);
        rotation_vector = axang(1:3) * axang(4);
        
        ur_poses(i, 1:3) = position;
        ur_poses(i, 4:6) = rotation_vector;
    end
end


function ur_poses = pathToURPoses_FixedX2(pathData, fixed_x_direction)
% 将路径数据转换为UR机器人位姿（X轴投影固定方法）
% 输入参数：
%   pathData: N×6矩阵，每行包含[x,y,z,nx,ny,nz] - 位置和法向量
%   fixed_x_direction: 1×3向量，期望的X轴投影方向
% 输出参数：
%   ur_poses: N×6矩阵，每行包含[x,y,z,rx,ry,rz] - 位置和旋转向量

    % 参数验证
    if nargin < 2
        fixed_x_direction = [1, 0, 0]; % 默认X方向
    end
    
    fixed_x_direction = fixed_x_direction / norm(fixed_x_direction);
    numPoints = size(pathData, 1);
    ur_poses = zeros(numPoints, 6);
    
    for i = 1:numPoints
        position = pathData(i, 1:3);
        normal = pathData(i, 4:6);
        
        % Z轴为法向量方向
        z_axis = normal / norm(normal);
        
        % 计算X轴：在垂直于Z轴的平面上的fixed_x_direction投影
        % 将固定方向投影到法向量的垂直平面上
        proj_x = fixed_x_direction - dot(fixed_x_direction, z_axis) * z_axis;
        
        % 如果投影很小，使用备选方法
        if norm(proj_x) < 1e-5
            % 如果固定方向与Z轴几乎平行，选择任意垂直方向
            if abs(z_axis(3)) > 0.9
                backup_dir = [0, 1, 0];
            else
                backup_dir = [0, 0, 1];
            end
            proj_x = backup_dir - dot(backup_dir, z_axis) * z_axis;
        end
        
        x_axis = proj_x / norm(proj_x);
        
        % Y轴由Z轴和X轴叉乘得到
        y_axis = cross(z_axis, x_axis);
        y_axis = y_axis / norm(y_axis);
        
        % 重新正交化X轴（确保坐标系是右手系）
        x_axis = cross(y_axis, z_axis);
        x_axis = x_axis / norm(x_axis);
        
        % 构建旋转矩阵并转换为旋转向量
        R = [x_axis', y_axis', z_axis'];
        axang = rotm2axang(R);
        rotation_vector = axang(1:3) * axang(4);
        
        ur_poses(i, 1:3) = position;
        ur_poses(i, 4:6) = rotation_vector;
    end
end
% 路径方向作为X轴版本
function ur_poses = pathToURPoses_PathDirectionX(pathData)
    numPoints = size(pathData, 1);
    ur_poses = zeros(numPoints, 6);
    
    for i = 1:numPoints
        position = pathData(i, 1:3);
        normal = pathData(i, 4:6);
        z_axis = normal / norm(normal);
        
        if i == 1
            next_pos = pathData(i+1, 1:3);
            path_direction = next_pos - position;
        elseif i == numPoints
            prev_pos = pathData(i-1, 1:3);
            path_direction = position - prev_pos;
        else
            prev_pos = pathData(i-1, 1:3);
            next_pos = pathData(i+1, 1:3);
            path_direction = (next_pos - prev_pos) / 2;
        end
        
        if norm(path_direction) > 1e-5
            x_axis_candidate = path_direction / norm(path_direction);
        else
            x_axis_candidate = [1, 0, 0];
        end
        
        proj_x_on_z = dot(x_axis_candidate, z_axis) * z_axis;
        x_axis_ortho = x_axis_candidate - proj_x_on_z;
        
        if norm(x_axis_ortho) < 1e-5
            if abs(z_axis(3)) > 0.9
                x_axis_ortho = [1, 0, 0] - dot([1, 0, 0], z_axis) * z_axis;
            else
                x_axis_ortho = [0, 0, 1] - dot([0, 0, 1], z_axis) * z_axis;
            end
        end
        
        x_axis = x_axis_ortho / norm(x_axis_ortho);
        y_axis = cross(z_axis, x_axis);
        y_axis = y_axis / norm(y_axis);
        
        R = [x_axis', y_axis', z_axis'];
        axang = rotm2axang(R);
        rotation_vector = axang(1:3) * axang(4);
        
        ur_poses(i, 1:3) = position;
        ur_poses(i, 4:6) = rotation_vector;
    end
end

function ur_waypoints = normals_to_ur_rpy(path_data, tool_y_axis_direction)
% 将包含位置和法向量的路径数据转换为UR的 [X, Y, Z, Rx, Ry, Rz] 格式
%
% 输入参数:
%   path_data - N×6矩阵，列顺序为 [X, Y, Z, Nx, Ny, Nz]
%   tool_y_axis_direction - (可选) 1×3向量，表示工具Y轴的大致方向，默认为 [0, 1, 0]
%
% 输出参数:
%   ur_waypoints - N×6矩阵，列顺序为 [X, Y, Z, Rx, Ry, Rz] (弧度制)

    % 设置默认的工具Y轴方向（世界坐标的Y轴正方向）
    if nargin < 2
        tool_y_axis_direction = [0, 1, 0];
    end
    
    % 获取数据点数量
    num_points = size(path_data, 1);
    
    % 预分配输出矩阵
    ur_waypoints = zeros(num_points, 6);
    
    % 遍历每一个路径点
    for i = 1:num_points
        % 提取当前位置和法向量
        xyz = path_data(i, 1:3);
        normal_vector = path_data(i, 4:6);
        
        % 1. 将法向量归一化，作为工具的Z轴
        z_axis = normal_vector / norm(normal_vector);
        
        % 2. 计算工具的X轴：参考Y方向与工具Z轴的叉积
        x_axis = cross(tool_y_axis_direction, z_axis);
        
        % 检查叉积结果是否接近零向量（平行情况）
        if norm(x_axis) < 1e-6
            % 如果法向量与参考Y方向平行，改用X轴方向计算
            x_axis = cross([1, 0, 0], z_axis);
        end
        x_axis = x_axis / norm(x_axis); % 归一化X轴
        
        % 3. 重新计算精确的Y轴：Z轴 × X轴
        y_axis = cross(z_axis, x_axis);
        
        % 4. 构建旋转矩阵 [X_axis, Y_axis, Z_axis]
        R = [x_axis', y_axis', z_axis'];
        
        % 5. 将旋转矩阵转换为固定轴的RPY欧拉角 (Z-Y-X顺序)
        % 计算Ry角
        ry = atan2(-R(3,1), sqrt(R(1,1)^2 + R(2,1)^2));
        
        % 检查是否接近奇异点（万向节锁）
        if abs(cos(ry)) > 1e-12
            % 正常情况
            rx = atan2(R(3,2)/cos(ry), R(3,3)/cos(ry));
            rz = atan2(R(2,1)/cos(ry), R(1,1)/cos(ry));
        else
            % 万向节锁情况 (Ry = ±pi/2)
            rz = 0; % 可以任意设定，这里设为0
            if ry > 0 % Ry = +pi/2
                ry = pi/2;
                rx = -rz + atan2(-R(1,2), -R(1,3));
            else % Ry = -pi/2
                ry = -pi/2;
                rx = rz + atan2(R(1,2), R(1,3));
            end
        end
        
        % 6. 组合位置和欧拉角
        ur_waypoints(i, :) = [xyz, rx, ry, rz];
    end
    
    % 显示转换完成信息
    fprintf('转换完成！共处理了 %d 个路径点。\n', num_points);
end

function [P] = computeOffsetVerticesV3(TR, offsetDistance)
    % 函数功能：计算顶点偏移后的点集，处理重复顶点
    % 输入参数：
    %   - TR: 三角剖分对象（包含 vertices 和 faces）
    %   - offsetDistance: 顶点偏移的距离
    % 输出参数：
    %   - P: 偏移后的顶点集

    vertices = TR.vertices;
    faces = TR.faces;

    % 去重顶点并重新映射面片索引
    [uniqueVertices, ~, vertexMap] = unique(vertices, 'rows');
    faces = vertexMap(faces); % 更新面片索引

    numVertices = size(uniqueVertices, 1);
    numTriangles = size(faces, 1);

    % 计算每个三角形的法向量
    v1 = uniqueVertices(faces(:, 1), :);
    v2 = uniqueVertices(faces(:, 2), :);
    v3 = uniqueVertices(faces(:, 3), :);
    u = v2 - v1;
    v = v3 - v1;
    faceNormals = cross(u, v, 2);
    faceNormals = faceNormals ./ vecnorm(faceNormals, 2, 2); % 归一化

    % 初始化顶点法向量
    vertexNormals = zeros(numVertices, 3);

    % 计算每个顶点的法向量（平均相邻面的法向量）
    for i = 1:numVertices
        % 找到包含当前顶点的所有面
        adjacentFaces = any(faces == i, 2);
        vertexNormals(i, :) = mean(faceNormals(adjacentFaces, :), 1);
    end
    vertexNormals = vertexNormals ./ vecnorm(vertexNormals, 2, 2); % 归一化

    % 偏移顶点
    offsetVertices = uniqueVertices + offsetDistance * vertexNormals;

    % 将偏移后的顶点映射回原始顶点顺序
    P = offsetVertices(vertexMap, :);
end

function [pose1_current_m,joint_current_rad] = InfoFromRobot(client)
    % 读取当前关节数据
    % 接收到的数据中第一位为总接收数据个数，第32-37位为关节角度
    header = fread(client, 1, 'int');  % 使用read替代fread
    msg = fread(client, 64, 'double');
    
    joint_current_rad = msg(32:37);
    joint_current_deg = rad2deg(joint_current_rad);  % 弧度转角度
    disp('当前关节 [A, B, C, D, E, F]:');
    fprintf('A: %.4f °, B: %.4f °, C: %.4f °\n', ...
    joint_current_deg(1), joint_current_deg(2), joint_current_deg(3));
    fprintf('D: %.4f °, E: %.4f °, F: %.4f °\n', ...
    joint_current_deg(4), joint_current_deg(5), joint_current_deg(6));
    
    pose1_current_m = msg(56:61);
    pose1_current_mm = pose1_current_m;
    pose1_current_mm(1:3) = pose1_current_m(1:3)*1000;  % 转换为毫米
    disp('当前工具位姿 [X, Y, Z, Rx, Ry, Rz]:');
    fprintf('X: %.4f mm, Y: %.4f mm, Z: %.4f mm\n', ...
    pose1_current_mm(1), pose1_current_mm(2), pose1_current_mm(3));
    fprintf('Rx: %.4f rad, Ry: %.4f rad, Rz: %.4f rad\n', ...
    pose1_current_mm(4), pose1_current_mm(5), pose1_current_mm(6));
end

function [URGcode] = generateURGcodeABSV2(pathOnelayer,homePos_mm,currentPos_XYZ_mm,RXYZ,V,Pressure)
    digital_out_port = 7;
    digital_out_Value_Start = 'False';
    digital_out_Value_Mid = 'False';
    digital_out_Value_End = 'False';
    analog_out_port = 0;
    P = (0.1/88)*Pressure;
    analog_out_Value = P;%0-1对应0-10v又对应比例阀供气0-900Kpa，考虑到最大为400Kpa，所以气压设置在0-0.45之间
    Rx0 = RXYZ(1);
    Ry0 = RXYZ(2);
    Rz0 = RXYZ(3);
    V = V/1000;
    Vk = 10/1000;
    HomePosition_m = homePos_mm/1000;%mm->m
    %头部代码
    moduleHeader = [
                    "  set_digital_out(%d, %s)"
                    "  sleep(0.01)"
                    "  set_analog_out(%d, %.2f)\n"
                   ]; 
    URGcode = sprintf(strjoin(moduleHeader, newline),digital_out_port,digital_out_Value_Start,analog_out_port,analog_out_Value);%IO设置
    URGcode = URGcode + sprintf('  movej(p[ %.5f, %.5f, %.5f, %.4f, %.4f, %.4f], a=0.8, v=%.5f, r=0.002)\n',HomePosition_m(1),HomePosition_m(2),HomePosition_m(3),Rx0,Ry0,Rz0,Vk);%移动到home点


   %中间代码
    for i = 1:length(pathOnelayer)
%         p1 = currentPos_XYZ_mm(1)/1000+pathOnelayer(i,1)/1000;
%         p2 = currentPos_XYZ_mm(2)/1000+pathOnelayer(i,2)/1000;
%         p3 = currentPos_XYZ_mm(3)/1000+pathOnelayer(i,3)/1000;
        p1 = pathOnelayer(i,1)/1000;
        p2 = pathOnelayer(i,2)/1000;
        p3 = pathOnelayer(i,3)/1000;
        Rx = pathOnelayer(i,4);
        Ry = pathOnelayer(i,5);
        Rz = pathOnelayer(i,6);
        if(pathOnelayer(i,7)==1)
            analog_out_Value_Mid = P;
            digital_out_Value_Mid = 'True';
        else
            analog_out_Value_Mid = 0;
            digital_out_Value_Mid = 'False';  
        end
        if(i==1)
            URGcode = URGcode + sprintf('  set_analog_out(%d, %.2f)\n',analog_out_port,analog_out_Value_Mid);
            URGcode = URGcode + sprintf('  sleep(0.01)\n');
            URGcode = URGcode + sprintf('  set_digital_out(%d, %s)\n',digital_out_port,digital_out_Value_Mid);
            URGcode = URGcode + sprintf('  movep(p[ %.5f, %.5f, %.5f, %.4f, %.4f, %.4f], a=1.2, v=%.5f, r=0.0005)\n',p1+0.005,p2+0.005,HomePosition_m(3),Rx,Ry,Rz,V*2);
            URGcode = URGcode + sprintf('  set_analog_out(%d, %.2f)\n',analog_out_port,analog_out_Value_Mid);
            URGcode = URGcode + sprintf('  sleep(0.01)\n');
            URGcode = URGcode + sprintf('  set_digital_out(%d, %s)\n',digital_out_port,digital_out_Value_Mid);
            URGcode = URGcode + sprintf('  movep(p[ %.5f, %.5f, %.5f, %.4f, %.4f, %.4f], a=1.2, v=%.5f, r=0.0005)\n',p1,p2,p3,Rx,Ry,Rz,V);
        elseif(i==2)
            URGcode = URGcode + sprintf('  set_analog_out(%d, %.2f)\n',analog_out_port,analog_out_Value_Mid);
            URGcode = URGcode + sprintf('  sleep(0.01)\n');
            URGcode = URGcode + sprintf('  set_digital_out(%d, %s)\n',digital_out_port,digital_out_Value_Mid);
            URGcode = URGcode + sprintf('  sleep(0.8)\n');
            URGcode = URGcode + sprintf('  movep(p[ %.5f, %.5f, %.5f, %.4f, %.4f, %.4f], a=1.2, v=%.5f, r=0.0005)\n',p1,p2,p3,Rx,Ry,Rz,V);
        else
%             URGcode = URGcode + sprintf('  set_analog_out(%d, %.2f)\n',analog_out_port,analog_out_Value_Mid);
            %URGcode = URGcode + sprintf('  sleep(0.01)\n');
            %URGcode = URGcode + sprintf('  set_digital_out(%d, %s)\n',digital_out_port,digital_out_Value_Mid);
            URGcode = URGcode + sprintf('  movep(p[ %.5f, %.5f, %.5f, %.4f, %.4f, %.4f], a=1.2, v=%.5f, r=0.0005)\n',p1,p2,p3,Rx,Ry,Rz,V);
        end
  
    end

    %尾部代码
    moduleFooter = [
                    "  set_analog_out(%d, %.2f)\n"
                    %"  sleep(0.01)"
                    %"  set_digital_out(%d, %s)\n"
                   ]; 
    %URGcode = URGcode + newline + sprintf(strjoin(moduleFooter, newline),analog_out_port,0,digital_out_port,digital_out_Value_End);%IO设置
    URGcode = URGcode + newline + sprintf(strjoin(moduleFooter, newline),analog_out_port,0);%IO设置
    URGcode = URGcode + sprintf('  movep(p[ %.5f, %.5f, %.5f, %.4f, %.4f, %.4f], a=0.8, v=%.5f, r=0.001)\n',p1,p2,HomePosition_m(3),Rx,Ry,Rz,Vk);%抬针
    URGcode = URGcode + sprintf('  movep(p[ %.5f, %.5f, %.5f, %.4f, %.4f, %.4f], a=0.8, v=%.5f, r=0.001)\n',HomePosition_m(1),HomePosition_m(2),HomePosition_m(3),Rx,Ry,Rz,Vk);%回home点
   
end


function [URGcode] = generateURGcodeABS(pathOnelayer,homePos_mm,currentPos_XYZ_mm,RXYZ,V,Pressure)
    digital_out_port = 7;
    digital_out_Value_Start = 'False';
    digital_out_Value_Mid = 'False';
    digital_out_Value_End = 'False';
    analog_out_port = 0;
    P = (0.1/88)*Pressure;
    analog_out_Value = P;%0-1对应0-10v又对应比例阀供气0-900Kpa，考虑到最大为400Kpa，所以气压设置在0-0.45之间
    Rx0 = RXYZ(1);
    Ry0 = RXYZ(2);
    Rz0 = RXYZ(3);
    V = V/1000;
    Vk = 10/1000;
    HomePosition_m = homePos_mm/1000;%mm->m
    %头部代码
    moduleHeader = [
                    "  set_digital_out(%d, %s)"
                    "  sleep(0.01)"
                    "  set_analog_out(%d, %.2f)\n"
                   ]; 
    URGcode = sprintf(strjoin(moduleHeader, newline),digital_out_port,digital_out_Value_Start,analog_out_port,analog_out_Value);%IO设置
    URGcode = URGcode + sprintf('  movej(p[ %.5f, %.5f, %.5f, %.4f, %.4f, %.4f], a=0.8, v=%.5f, r=0.002)\n',HomePosition_m(1),HomePosition_m(2),HomePosition_m(3),Rx0,Ry0,Rz0,Vk);%移动到home点


   %中间代码
    for i = 1:length(pathOnelayer)
%         p1 = currentPos_XYZ_mm(1)/1000+pathOnelayer(i,1)/1000;
%         p2 = currentPos_XYZ_mm(2)/1000+pathOnelayer(i,2)/1000;
%         p3 = currentPos_XYZ_mm(3)/1000+pathOnelayer(i,3)/1000;
        p1 = pathOnelayer(i,1)/1000;
        p2 = pathOnelayer(i,2)/1000;
        p3 = pathOnelayer(i,3)/1000;
        Rx = pathOnelayer(i,4);
        Ry = pathOnelayer(i,5);
        Rz = pathOnelayer(i,6);
        if(pathOnelayer(i,7)==1)
            analog_out_Value_Mid = P;
            digital_out_Value_Mid = 'True';
        else
            analog_out_Value_Mid = 0;
            digital_out_Value_Mid = 'False';  
        end
        if(i==1)
            URGcode = URGcode + sprintf('  set_analog_out(%d, %.2f)\n',analog_out_port,analog_out_Value_Mid);
            URGcode = URGcode + sprintf('  sleep(0.01)\n');
            URGcode = URGcode + sprintf('  set_digital_out(%d, %s)\n',digital_out_port,digital_out_Value_Mid);
            URGcode = URGcode + sprintf('  movep(p[ %.5f, %.5f, %.5f, %.4f, %.4f, %.4f], a=5, v=%.5f, r=0.0005)\n',p1+0.005,p2+0.005,HomePosition_m(3),Rx,Ry,Rz,V*2);
            URGcode = URGcode + sprintf('  set_analog_out(%d, %.2f)\n',analog_out_port,analog_out_Value_Mid);
            URGcode = URGcode + sprintf('  sleep(0.01)\n');
            URGcode = URGcode + sprintf('  set_digital_out(%d, %s)\n',digital_out_port,digital_out_Value_Mid);
            URGcode = URGcode + sprintf('  movep(p[ %.5f, %.5f, %.5f, %.4f, %.4f, %.4f], a=5, v=%.5f, r=0.0005)\n',p1,p2,p3,Rx,Ry,Rz,V);
        elseif(i==2)
            URGcode = URGcode + sprintf('  set_analog_out(%d, %.2f)\n',analog_out_port,analog_out_Value_Mid);
            URGcode = URGcode + sprintf('  sleep(0.01)\n');
            URGcode = URGcode + sprintf('  set_digital_out(%d, %s)\n',digital_out_port,digital_out_Value_Mid);
            URGcode = URGcode + sprintf('  movep(p[ %.5f, %.5f, %.5f, %.4f, %.4f, %.4f], a=5, v=%.5f, r=0.0005)\n',p1,p2,p3,Rx,Ry,Rz,V);
        else
            URGcode = URGcode + sprintf('  set_analog_out(%d, %.2f)\n',analog_out_port,analog_out_Value_Mid);
            %URGcode = URGcode + sprintf('  sleep(0.01)\n');
            %URGcode = URGcode + sprintf('  set_digital_out(%d, %s)\n',digital_out_port,digital_out_Value_Mid);
            URGcode = URGcode + sprintf('  movep(p[ %.5f, %.5f, %.5f, %.4f, %.4f, %.4f], a=5, v=%.5f, r=0.0005)\n',p1,p2,p3,Rx,Ry,Rz,V);
        end
  
    end

    %尾部代码
    moduleFooter = [
                    "  set_analog_out(%d, %.2f)\n"
                    %"  sleep(0.01)"
                    %"  set_digital_out(%d, %s)\n"
                   ]; 
    %URGcode = URGcode + newline + sprintf(strjoin(moduleFooter, newline),analog_out_port,0,digital_out_port,digital_out_Value_End);%IO设置
    URGcode = URGcode + newline + sprintf(strjoin(moduleFooter, newline),analog_out_port,0);%IO设置
    URGcode = URGcode + sprintf('  movep(p[ %.5f, %.5f, %.5f, %.4f, %.4f, %.4f], a=0.8, v=%.5f, r=0.001)\n',p1,p2,HomePosition_m(3),Rx,Ry,Rz,Vk);%抬针
    URGcode = URGcode + sprintf('  movep(p[ %.5f, %.5f, %.5f, %.4f, %.4f, %.4f], a=0.8, v=%.5f, r=0.001)\n',HomePosition_m(1),HomePosition_m(2),HomePosition_m(3),Rx,Ry,Rz,Vk);%回home点
   
end

function cleanedArray = removeDuplicateXYZ(originalArray)
    % 提取 XYZ 坐标（前三列）
    xyz = originalArray(:, 1:3);
    
    % 找到唯一的 XYZ 行，并返回它们的首次出现索引
    [~, uniqueIndices] = unique(xyz, 'rows', 'first');
    
    % 确保索引按原始顺序排列（避免打乱数据）
    uniqueIndices = sort(uniqueIndices);
    
    % 提取唯一行（保留所有列，包括标志位）
    cleanedArray = originalArray(uniqueIndices, :);
end

function point_normals = assignPointNormalsFast(points, vertices, faces, face_normals)
    % 高效版本：为路径点分配法向
    % points: Nx3 点集
    % vertices: Mx3 顶点坐标
    % faces: Kx3 面片索引
    % face_normals: Kx3 面法向
    face_normals = face_normals';
    num_points = size(points, 1);
    point_normals = zeros(num_points, 3);
    
    % 预计算和缓存
    % 1. 预计算所有面片的中心点
    face_centroids = zeros(size(faces, 1), 3);
    for i = 1:size(faces, 1)
        face_centroids(i, :) = mean(vertices(faces(i, :), :), 1);
    end
    
    % 2. 构建整个网格的KD-Tree（只构建一次）
    kdtree_faces = KDTreeSearcher(face_centroids);
    kdtree_vertices = KDTreeSearcher(vertices);
    
    % 3. 预计算顶点-面片关联关系
    vertex_to_faces = cell(size(vertices, 1), 1);
    for i = 1:size(faces, 1)
        for j = 1:3
            vertex_idx = faces(i, j);
            vertex_to_faces{vertex_idx} = [vertex_to_faces{vertex_idx}, i];
        end
    end
    
    % 批量处理点
    % 1. 首先为所有点找到候选面片
    candidate_faces = cell(num_points, 1);
    candidate_weights = cell(num_points, 1);
    
    % 批量查找最近的面片中心（比逐个查找快得多）
    [face_indices, face_distances] = knnsearch(kdtree_faces, points, 'K', min(5, size(faces, 1)));
    
    for i = 1:num_points
        current_point = points(i, :);
        
        % 方法1：检查最近的面片是否包含该点
        found_containing = false;
        containing_faces = [];
        face_weights = [];
        
        for k = 1:size(face_indices, 2)
            face_idx = face_indices(i, k);
            v1 = vertices(faces(face_idx, 1), :);
            v2 = vertices(faces(face_idx, 2), :);
            v3 = vertices(faces(face_idx, 3), :);
            
            if isPointInTriangleFast(current_point, v1, v2, v3)
                containing_faces = [containing_faces, face_idx];
                % 使用距离的倒数作为权重
                weight = 1 / (face_distances(i, k) + eps);
                face_weights = [face_weights, weight];
                found_containing = true;
            end
        end
        
        % 方法2：如果没找到包含的面片，使用顶点关联的面片
        if ~found_containing
            % 找到最近的顶点
            [vertex_idx, vertex_dist] = knnsearch(kdtree_vertices, current_point);
            
            % 获取与该顶点关联的所有面片
            associated_faces = vertex_to_faces{vertex_idx};
            
            % 计算这些面片的权重（基于点到面片的距离）
            containing_faces = associated_faces;
            face_weights = zeros(1, length(associated_faces));
            
            for j = 1:length(associated_faces)
                face_idx = associated_faces(j);
                centroid = face_centroids(face_idx, :);
                distance = norm(current_point - centroid);
                face_weights(j) = 1 / (distance + eps);
            end
        end
        
        candidate_faces{i} = containing_faces;
        candidate_weights{i} = face_weights;
    end
    
    % 批量计算法向
    for i = 1:num_points
        containing_faces = candidate_faces{i};
        weights = candidate_weights{i};
        
        if ~isempty(containing_faces)
            % 加权平均法向
            total_weight = sum(weights);
            weighted_normal = zeros(1, 3);
            
            for j = 1:length(containing_faces)
                face_idx = containing_faces(j);
                weighted_normal = weighted_normal + weights(j) * face_normals(face_idx, :);
            end
            
            point_normals(i, :) = weighted_normal / total_weight;
            point_normals(i, :) = point_normals(i, :) / norm(point_normals(i, :));
        else
            % 使用最近面片的法向
            closest_face = face_indices(i, 1);
            point_normals(i, :) = face_normals(closest_face, :);
        end
    end
end

function inside = isPointInTriangleFast1(point, v1, v2, v3)
    % 快速版本的点在三角形内判断
    % 使用重心坐标方法，但避免不必要的计算
    
    % 计算三角形法向
    normal = cross(v2 - v1, v3 - v1);
    
    % 选择投影平面（忽略法向最大的维度，数值稳定性更好）
    [~, drop_dim] = max(abs(normal));
    keep_dims = setdiff(1:3, drop_dim);
    
    % 提取二维坐标
    p = point(keep_dims);
    a = v1(keep_dims);
    b = v2(keep_dims);
    c = v3(keep_dims);
    
    % 计算重心坐标
    v0 = c - a;
    v1_vec = b - a;
    v2_vec = p - a;
    
    dot00 = dot(v0, v0);
    dot01 = dot(v0, v1_vec);
    dot02 = dot(v0, v2_vec);
    dot11 = dot(v1_vec, v1_vec);
    dot12 = dot(v1_vec, v2_vec);
    
    inv_denom = 1 / (dot00 * dot11 - dot01 * dot01);
    u = (dot11 * dot02 - dot01 * dot12) * inv_denom;
    v = (dot00 * dot12 - dot01 * dot02) * inv_denom;
    
    % 添加容差，提高鲁棒性
    tolerance = -1e-10;
    inside = (u >= tolerance) && (v >= tolerance) && (u + v <= 1 - tolerance);
end

function[orderALLPoints] = genPath(cellPoints,celledges,contour,X)
    X = X';
    pointend = cellPoints{1};
    pointstart = cellPoints{1};
    orderALLPoints = [];
    edgesend = celledges{1};
    edgesend = edgesend(1,:);
    for i = 2:length(cellPoints)-1
        points = cellPoints{i};
        edges = celledges{i};%会出现多个的情况，还需要处理
        if(isempty(points))
            break;
        end
        %首次连接判定
            % 定义三个点的坐标
            Ps = pointstart;
            Pe = pointend;
            P1 = points(:,1);
            P2 = points(:,2);
            % 计算 P0 到 P1 和 P0 到 P2 的距离
            distancee1 = norm(P1 - Pe);
            distancee2 = norm(P2 - Pe);
            distances1 = norm(P2 - Ps);
            distances2 = norm(P2 - Ps);
            % 比较距离
            if distancee1 > distancee2
              points = [points(:,2),points(:,3:end),points(:,1)];
              edges = [edges(2,:);edges(1,:)];
            elseif distancee1 < distancee2
              points = [points(:,1),points(:,3:end),points(:,2)];
              edges = [edges(1,:);edges(2,:)];
            else
                if(i==2)
                  points = [points(:,1),points(:,3:end),points(:,2)];
                  edges = [edges(1,:);edges(2,:)];
                else 
                    if(distances1>distances2)
                      points = [points(:,1),points(:,3:end),points(:,2)];
                      edges = [edges(1,:);edges(2,:)];
                    elseif(distances1<=distances2)
                      points = [points(:,2),points(:,3:end),points(:,1)];
                      edges = [edges(2,:);edges(1,:)];
                    end
                end
            end
        orderedPoints = Points2Path(points);
        orderedPoints = unique(orderedPoints,"rows","stable");
        orderlength = length(orderedPoints);
        %处理上一个最终点和排好点之间的链接
        if(i==2)%初始点处理(需要优化)
           p1 = edgesend(1);
           p2 = edges(1,2);
           row1 = find(contour == p1);
           row2 = find(contour == p2);
           if(row2>row1)
               interPointsindex= contour(row1+1:row2-1);
           else
               if((row1-row2)>0.7*length(contour))
                  interPointsindex2 = contour(1:row2-1);
                  interPointsindex1 = contour(row1+1:end);
                  interPointsindex = [interPointsindex1,interPointsindex2];
               else
                  interPointsindex = contour(row2+1:row1-1);
                  interPointsindex = interPointsindex(end:-1:1);
               end
           end
           interpoints = X(:,interPointsindex);
           interpoints = interpoints';
           orderedPoints = [pointend';interpoints;orderedPoints];
           edgesend = edges(2,:);
        elseif(edges(1,1)==edgesend(1)&&edges(1,2)==edgesend(2))
           orderedPoints = [pointend';orderedPoints];
           edgesend = edges(2,:);
        else%需要优化（检查)
           p1 = edgesend(1);
           p2 = edges(1,2);
           row1 = find(contour == p1);
           row2 = find(contour == p2);
           if(row2>row1)
               interPointsindex= contour(row1+1:row2-1);
           else
               if((row1-row2)>0.7*length(contour))
                  interPointsindex2 = contour(1:row2-1);
                  interPointsindex1 = contour(row1+1:end);
                  interPointsindex = [interPointsindex1,interPointsindex2];
               else
                  interPointsindex = contour(row2+1:row1-1);
                  interPointsindex = interPointsindex(end:-1:1);
               end
               
           end
           interpoints = X(:,interPointsindex);
           interpoints = interpoints';
           orderedPoints = [pointend';interpoints;orderedPoints];
           edgesend = edges(2,:);
        end
        pointend = orderedPoints(end,:);
        pointstart = orderedPoints(length(orderedPoints)-orderlength+1,:);
        pointend = pointend';
        orderALLPoints = [orderALLPoints;orderedPoints];
    end

    % %终点处理
    pointsF = cellPoints{i+1};
    edges = celledges{i+1};%会出现多个的情况，还需要处理
    p1 = edgesend(1);
    p2 = edges(1,2);
    row1 = find(contour == p1);
    row2 = find(contour == p2);
    if(row2>row1)
       interPointsindex= contour(row1+1:row2-1);
    else
       if((row1-row2)>0.7*length(contour))
          interPointsindex2 = contour(1:row2-1);
          interPointsindex1 = contour(row1+1:end);
          interPointsindex = [interPointsindex1,interPointsindex2];
       else
          interPointsindex = contour(row2+1:row1-1);
          interPointsindex = interPointsindex(end:-1:1);
       end
    end
    interpoints = X(:,interPointsindex);
    interpoints = interpoints';
    orderedPoints = [pointend';interpoints;pointsF'];
    orderALLPoints = [orderALLPoints;orderedPoints];
    orderALLPoints = unique(orderALLPoints,"rows","stable");
%     plot3(orderALLPoints(:,1),orderALLPoints(:,2),orderALLPoints(:,3),'-r.');
%     xlabel('X');  
%     ylabel('Y');  
%     zlabel('Z');
end

function[cellPoints,celledges] = equalGeodesicDistance(D,step,X,F,boundary_edges)
    X = X';
    F = F';
    [rangeALL,idx] = max(D);%☆=============================================================
    rangeSearch = 3;
    %step = 0.5;%☆=============================================================
    cellPoints ={};
    celledges = {};
    for i = 0:floor(rangeALL/step)
        phi0 = i*step; 
        [PhiTipPoint,edges,Phi0points] = getEqualGeodesicPointsV2(phi0,rangeSearch,D,X,F,boundary_edges);
        Phi0points = unique(Phi0points',"rows","stable");
        Phi0points2 = [PhiTipPoint';Phi0points];
        Phi0points2 = unique(Phi0points2,"rows","stable");
        cellPoints{i+1} = Phi0points2';
        celledges{i+1} = edges;
    end
    pFinal = X(:,idx);
    cellPoints{i+2} = pFinal;
    [col1,row1] = find(boundary_edges(:,1) == idx);
    [col2,row2] = find(boundary_edges(:,2) == idx);
    mergedArray = union(col1, col2);
    edgeFinal = boundary_edges(mergedArray,:);
    celledges{i+2} = edgeFinal;
end

function [boundary_edges, contours] = extract_boundary_contours(V, F)
    % 提取所有边并按升序排列顶点
    edges = [];
    for i = 1:size(F, 1)
        v = F(i, :);
        edges = [edges; 
                 sort([v(1), v(2)]);
                 sort([v(2), v(3)]);
                 sort([v(3), v(1)])];
    end
    
    % 统计唯一边及其出现次数
    [unique_edges, ~, ic] = unique(edges, 'rows');
    counts = accumarray(ic, 1);
    boundary_edges = unique_edges(counts == 1, :);
    
    % 构建邻接表
    if isempty(boundary_edges)
        contours = {};
        return;
    end
    max_vertex = max(boundary_edges(:));
    adj_list = cell(max_vertex, 1);
    for i = 1:size(boundary_edges, 1)
        v1 = boundary_edges(i, 1);
        v2 = boundary_edges(i, 2);
        adj_list{v1} = [adj_list{v1}, v2];
        adj_list{v2} = [adj_list{v2}, v1];
    end
    
    % 提取有序轮廓线
    contours = {};
    while true
        % 寻找起始顶点
        start_v = find(~cellfun(@isempty, adj_list), 1);
        if isempty(start_v)
            break;
        end
        
        current_v = start_v;
        contour = current_v;
        while true
            if isempty(adj_list{current_v})
                break;
            end
            next_v = adj_list{current_v}(1);
            % 移除当前边
            adj_list{current_v}(1) = [];
            adj_list{next_v}(adj_list{next_v} == current_v) = [];
            contour = [contour, next_v];
            current_v = next_v;
            % 闭合检测
            if current_v == start_v
                break;
            end
        end
        contours{end+1} = contour;
    end
end

function[D,isCloseTarget] = getGeodesicDistance(X,F,target_point,isCloseTarget)
    n = size(X,1);
    m = size(F,1);
    X = X';
    F = F';
    % Callback to get the coordinates of all the vertex of index \(i=1,2,3\) in all faces.
    XF = @(i)X(:,F(i,:));
    % Compute un-normalized normal through the formula \(e_1 \wedge e_2 \) where \(e_i\) are the edges.
    Na = cross( XF(2)-XF(1), XF(3)-XF(1) );
    % Compute the area of each face as half the norm of the cross product.
    amplitude = @(X)sqrt( sum( X.^2 ) );
    A = amplitude(Na)/2;
    % Compute the set of unit-norm normals to each face.
    normalize = @(X)X ./ repmat(amplitude(X), [3 1]);
    N = normalize(Na); %计算模型三角形面片的所有法向
    % Populate the sparse entries of the matrices for the operator implementing \( \sum_{i \in f} u_i (N_f \wedge e_i) \).
    I = []; J = []; V = []; % indexes to build the sparse matrices
    for i=1:3
        % opposite edge e_i indexes
        s = mod(i,3)+1;
        t = mod(i+1,3)+1;
        % vector N_f^e_i
        wi = cross(XF(t)-XF(s),N);
        % update the index listing
        I = [I, 1:m];
        J = [J, F(i,:)];
        V = [V, wi];
    end
    % Sparse matrix with entries \(1/(2A_f)\).
    dA = spdiags(1./(2*A(:)),0,m,m);
    % Compute gradient.
    GradMat = {};
    for k=1:3
        GradMat{k} = dA*sparse(I,J,V(k,:),m,n);
    end
    % \(\nabla\) gradient operator.
    Grad = @(u)[GradMat{1}*u, GradMat{2}*u, GradMat{3}*u]';
    % Compute divergence matrices as transposed of grad for the face area inner product.
    dAf = spdiags(2*A(:),0,m,m);
    DivMat = {GradMat{1}'*dAf, GradMat{2}'*dAf, GradMat{3}'*dAf};
    % Div operator.
    Div = @(q)DivMat{1}*q(1,:)' + DivMat{2}*q(2,:)' + DivMat{3}*q(3,:)';
    % Laplacian operator as the composition of grad and div.
    Delta = DivMat{1}*GradMat{1} + DivMat{2}*GradMat{2} + DivMat{3}*GradMat{3};
    % Cotan of an angle between two vectors.
    cota = @(a,b)cot( acos( dot(normalize(a),normalize(b)) ) );
    I = []; J = []; V = []; % indexes to build the sparse matrices
    Ia = []; Va = []; % area of vertices
    for i=1:3
        % opposite edge e_i indexes
        s = mod(i,3)+1;
        t = mod(i+1,3)+1;
        % adjacent edge
        ctheta = cota(XF(s)-XF(i), XF(t)-XF(i));
        % ctheta = max(ctheta, 1e-2); % avoid degeneracy
        % update the index listing
        I = [I, F(s,:), F(t,:)];
        J = [J, F(t,:), F(s,:)];
        V = [V, ctheta, ctheta];
        % update the diagonal with area of face around vertices
        Ia = [Ia, F(i,:)];
        Va = [Va, A];
    end
    % Aread diagonal matrix
    Ac = sparse(Ia,Ia,Va,n,n);
    % Cotan weights
    Wc = sparse(I,J,V,n,n);
    % Laplacian with cotan weights.
    DeltaCot = spdiags(full(sum(Wc))', 0, n,n) - Wc;
    % Check that the Laplacian with cotan weights is actually equal to the composition of divergence and gradient.
    fprintf('Should be 0: %e\n', norm(Delta-DeltaCot, 'fro')/norm(Delta, 'fro'));
    % Display a function \(f\) on the mesh.
    f = X(2,:);
%     options.face_vertex_color = f(:);
%     clf; plot_mesh(X,F,options);
%     axis('tight');
%     colormap parula(256);
    % Display its Laplacian.
    g = Delta*f(:);
    g = clamp(g, -3*std(g), 3*std(g));
%     options.face_vertex_color = rescale(g);
%     clf; plot_mesh(X,F,options);
%     axis('tight');
%     colormap parula(256);
    %☆Select index \(i\)======================================================
    %target_point = [0, 16, 12.5];
    points = X';
    distances = sqrt(sum((points - target_point).^ 2, 2));
    % 找到最近点的索引
    if(isCloseTarget)
        [~, idx] = min(distances);
        isCloseTarget = false;
    else
        [~, idx] = max(distances);
        isCloseTarget = true;
    end
    i = idx;
    % Set time \(t\).
    t = 1000;
    % Solve the linear system.
    delta = zeros(n,1);
    delta(i) = 1;
    u = (Ac+t*Delta)\delta;%左除
    % Display this solution.
    % options.face_vertex_color = u;
    % clf; plot_mesh(X,F,options);
    % axis('tight');
    % colormap parula(256);
    
    % Compute the solution \(u\) with explicit time stepping.
    t = 0.1;
    u = (Ac+t*DeltaCot)\delta;%左除
    % Compute the gradient field.
    g = Grad(u);
    % Normalize it to obtain \[ h = -\frac{\nabla u}{\norm{\nabla u}}. \]
    h = -normalize(g);
    % Integrate it back by solving \[ \Delta \phi = \text{div}(h). \]
    phi = Delta \ Div(h);
    D = phi-min(phi,[],'all');
    % Display.
    % options.face_vertex_color = D;
    % 
    % clf; plot_mesh(X,F,options);
    % axis('tight');
    % colormap parula(256);
end

function plot_coordinate_frame(R, origin, scale, frame_name)
    % X轴 (红色)
    quiver3(origin(1), origin(2), origin(3), R(1,1)*scale, R(2,1)*scale, R(3,1)*scale, ...
            'LineWidth', 3, 'Color', 'r', 'MaxHeadSize', 0.8);
    % Y轴 (绿色)
    quiver3(origin(1), origin(2), origin(3), R(1,2)*scale, R(2,2)*scale, R(3,2)*scale, ...
            'LineWidth', 3, 'Color', 'g', 'MaxHeadSize', 0.8);
    % Z轴 (蓝色)
    quiver3(origin(1), origin(2), origin(3), R(1,3)*scale, R(2,3)*scale, R(3,3)*scale, ...
            'LineWidth', 3, 'Color', 'b', 'MaxHeadSize', 0.8);
    
    % 坐标轴标签
    text(origin(1)+R(1,1)*scale*1.1, origin(2)+R(2,1)*scale*1.1, origin(3)+R(3,1)*scale*1.1, ...
         'X', 'Color', 'r', 'FontWeight', 'bold', 'FontSize', 12);
    text(origin(1)+R(1,2)*scale*1.1, origin(2)+R(2,2)*scale*1.1, origin(3)+R(3,2)*scale*1.1, ...
         'Y', 'Color', 'g', 'FontWeight', 'bold', 'FontSize', 12);
    text(origin(1)+R(1,3)*scale*1.1, origin(2)+R(2,3)*scale*1.1, origin(3)+R(3,3)*scale*1.1, ...
         'Z', 'Color', 'b', 'FontWeight', 'bold', 'FontSize', 12);
    
    % 坐标系名称
    if nargin > 3
        text(origin(1), origin(2), origin(3)-scale*0.5, frame_name, ...
             'FontSize', 10, 'HorizontalAlignment', 'center', 'BackgroundColor', 'white');
    end
    hold on;
end

function [] = showMesh(F,V)
    P = V;% 这就是你需要的顶点信息
%     figure(1);clf;
    scatter3(P(:,1),P(:,2),P(:,3),5,'r','filled')%画散点（点云）
    view(-30,40);axis('equal')
    hold on
    CL = F;%连接列表
%     figure(2);clf;
    patch('vertices', P, 'faces', CL, 'facevertexcdata',P(:,3), 'facecolor', 'interp');%以z方向坐标作为颜色画出立体图
    colormap(jet);view(-30,40);axis('equal')
    xlabel('X');  
    ylabel('Y');  
    zlabel('Z');
    hold on
end


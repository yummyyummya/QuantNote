
%% PART1 根据P/C情绪指标进行多空判断
% option.mat中的数据主要存储在database结构体中，Date表示日期，Data_Call表示当天所有的看涨期权的收盘价、成交量、成交额和持仓量
load option.mat;

% 计算每日看涨看跌期权的成交量、持仓量、成交额等
N = size(database,2);
Volume_Call = zeros(N,1); % 成交量
Volume_Put = zeros(N,1);

AMT_Call = zeros(N,1); % 成交额
AMT_Put = zeros(N,1);

Pos_Call = zeros(N,1); % 持仓量
Pos_Put = zeros(N,1);

for i = 1:N
    Volume_Call(i) = sum(database(i).Data_Call(:,2));
    Volume_Put(i) = sum(database(i).Data_Put(:,2));
    AMT_Call(i) = sum(database(i).Data_Call(:,3));
    AMT_Put(i) = sum(database(i).Data_Put(:,3));
    Pos_Call(i) = sum(database(i).Data_Call(:,4));
    Pos_Put(i) = sum(database(i).Data_Put(:,4));
end

Volume = Volume_Call + Volume_Put;
AMT = AMT_Call + AMT_Put;
Pos = Pos_Call + Pos_Put;

Volume_Ratio = Volume_Put ./ Volume_Call;
AMT_Ratio = AMT_Put ./ AMT_Call;
Pos_Ratio = Pos_Put ./ Pos_Call;


%% 绘图观察相关性
h = figure;
[hAx,hLine1, hLine2] = plotyy([1:277], ETF, [1:277], Volume_Ratio);
hLine1.LineStyle = '-';
hLine1.Color = 'r';
hLine1.LineWidth = 1.5;
hLine2.LineStyle = '-';
hLine2.LineWidth = 1.5;
hLine2.Color = 'b';
grid on;
axis1 = h.Children(1);
axis1.YLim = [0 2.0];
axis1.YTick = [0:0.5:2.0];
axis1.XLim = [1 277];
axis2 = h.Children(2);
axis2.XLim = [1 277];
title('ETF价格与成交量走势');



h = figure;
[hAx,hLine1, hLine2] = plotyy([1:277], ETF, [1:277], AMT_Ratio);
hLine1.LineStyle = '-';
hLine1.Color = 'r';
hLine1.LineWidth = 1.5;
hLine2.LineStyle = '-';
hLine2.LineWidth = 1.5;
hLine2.Color = 'b';
grid on;
axis1 = h.Children(1);
axis1.YLim = [0 10.0];
axis1.YTick = [0:0.5:2.0];
axis1.XLim = [1 277];
axis2 = h.Children(2);
axis2.YLim = [1.8 3.6];
axis2.YTick = [1.8:0.3:3.6];
axis2.XLim = [1 277];
title('ETF价格与成交额走势');


%% 策略构建
Volume_Diff = diff(Volume_Ratio);
AMT_Diff = diff(AMT_Ratio);

Volume_Logic = Volume_Diff < 0;
AMT_Logic = AMT_Diff < 0;

T = size(AMT_Logic,1);
Position_Volume = zeros(T,1);
Position_AMT = zeros(T,1);
Position_Volume(Volume_Logic) = 1;
Position_AMT(AMT_Logic) = 1;

price = ETF(2:end);

Ret_Volume = Position_Volume(1:end-1) .* ( (price(2:end) - price(1:end-1)) ./ price(1:end-1));
Ret_AMT = Position_AMT(1:end-1) .* ( (price(2:end) - price(1:end-1)) ./ price(1:end-1));
ret = price2ret(price);

xaxis = time(3:end);
h1 = figure;
plot(xaxis, cumsum(Ret_Volume),'r', 'LineWidth', 1.5);
hold on;
plot(xaxis, cumsum(Ret_AMT),'b', 'LineWidth', 1.5);
plot(xaxis, cumsum(ret),'k', 'LineWidth', 1.5);
axis = gca;
axis.XLim = [xaxis(1) xaxis(end)];
axis.XTick = xaxis(1:21:end);
axis.XTickLabel = datestr(axis.XTick, 'yy-mm-dd');
legend('Ret\_Volume', 'Ret\_AMT', 'Ret\_ETF');
grid on;
title('根据成交量PCR/成交额PCR判断开平仓信号 累计收益率');

%% 数据检验
% 我们ETF净值前一天的值对于后一天的值有非常明显的相关性，不管是方程整体还是系数本身
% 将残差对PCR进行分析我们可以发现，持仓量对于其解释能力要弱于成交量和成交额
price = ETF;
y = price(2:end);
x = [ones(size(y)), price(1:end-1)];
result1 = ols(y,x);
prt(result1);

y = result1.resid;
x = [ones(size(y)), Volume_Ratio(2:end)];
result2 = ols(y,x);
prt(result2);

y = result1.resid;
x = [ones(size(y)), AMT_Ratio(2:end)];
result3 = ols(y,x);
prt(result3);

y = result1.resid;
x = [ones(size(y)), Pos_Ratio(2:end)];
result4 = ols(y,x);
prt(result4);


%% 绘制ETF价格
% 考虑动量因素
[data, text] = xlsread('50ETF.xlsx');
figure;
plot(time, data(:,4),'LineWidth',1.5);
axis = gca;
axis.XTickLabel = datestr(axis.XTick, 'yy-mm-dd');


%% 期现套利
[c1,c2,c3,c4,c5,Future_Price,c7] = textread('CFFEX.txt','%s %s %f %f %f %f %f','delimiter',',');
figure;
[h, ax1, ax2] = plotyy([1:229], Future_Price(1:229), [1:229], ETF_Price);
ax1.LineWidth = 1.5;
ax2.LineWidth = 1.5;

% 期货收益率与现货收益率的差价比较
Diff = price2ret(Future_Price(1:229)) - price2ret(ETF_Price);
figure;
bar(Diff);
axis = gca;
axis.XLim = [1 228];

figure;

%% 买权-卖权平价理论(Put-Call Parity)
% 利用期权复制现货，进而与期货实现期限套利

% 选择9月到期的，行权价K=2.30的看跌看涨期权
K = 2.30;
r = 0.0435;
CP_Diff = CP(:,1) - CP(:,2);
Cash = K .* exp(-r.*([151:-1:0]./365));
Cash = Cash';
h = figure;
date=[736004;736005;time(1:150)];
plot(date, Price, 'r','LineWidth', 1.5);
hold on;
plot(date, CP_Diff + Cash, 'b', 'LineWidth', 1.5);
axis = gca;
axis.XLim = [date(1) date(end)];
axis.XTickLabel = datestr(axis.XTick, 'yy-mm-dd');
axis.YGrid ='on';
title('ETF期权复制现货价格')
























    
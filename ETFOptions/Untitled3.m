
%% PART1 ����P/C����ָ����ж���ж�
% option.mat�е�������Ҫ�洢��database�ṹ���У�Date��ʾ���ڣ�Data_Call��ʾ�������еĿ�����Ȩ�����̼ۡ��ɽ������ɽ���ͳֲ���
load option.mat;

% ����ÿ�տ��ǿ�����Ȩ�ĳɽ������ֲ������ɽ����
N = size(database,2);
Volume_Call = zeros(N,1); % �ɽ���
Volume_Put = zeros(N,1);

AMT_Call = zeros(N,1); % �ɽ���
AMT_Put = zeros(N,1);

Pos_Call = zeros(N,1); % �ֲ���
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


%% ��ͼ�۲������
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
title('ETF�۸���ɽ�������');



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
title('ETF�۸���ɽ�������');


%% ���Թ���
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
title('���ݳɽ���PCR/�ɽ���PCR�жϿ�ƽ���ź� �ۼ�������');

%% ���ݼ���
% ����ETF��ֵǰһ���ֵ���ں�һ���ֵ�зǳ����Ե�����ԣ������Ƿ������廹��ϵ������
% ���в��PCR���з������ǿ��Է��֣��ֲ����������������Ҫ���ڳɽ����ͳɽ���
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


%% ����ETF�۸�
% ���Ƕ�������
[data, text] = xlsread('50ETF.xlsx');
figure;
plot(time, data(:,4),'LineWidth',1.5);
axis = gca;
axis.XTickLabel = datestr(axis.XTick, 'yy-mm-dd');


%% ��������
[c1,c2,c3,c4,c5,Future_Price,c7] = textread('CFFEX.txt','%s %s %f %f %f %f %f','delimiter',',');
figure;
[h, ax1, ax2] = plotyy([1:229], Future_Price(1:229), [1:229], ETF_Price);
ax1.LineWidth = 1.5;
ax2.LineWidth = 1.5;

% �ڻ����������ֻ������ʵĲ�۱Ƚ�
Diff = price2ret(Future_Price(1:229)) - price2ret(ETF_Price);
figure;
bar(Diff);
axis = gca;
axis.XLim = [1 228];

figure;

%% ��Ȩ-��Ȩƽ������(Put-Call Parity)
% ������Ȩ�����ֻ����������ڻ�ʵ����������

% ѡ��9�µ��ڵģ���Ȩ��K=2.30�Ŀ���������Ȩ
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
title('ETF��Ȩ�����ֻ��۸�')
























    
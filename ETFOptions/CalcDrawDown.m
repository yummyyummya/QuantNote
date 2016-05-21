
% author: Y.ZHANG
% description: 计算收益率序列的回撤
% input:
%      ret: 收益率序列
% output:
%      DrawDown: 回撤大小

function [DrawDownPercent, DrawDownAbs] = CalcDrawDown(ret)
  len = size(ret,1);
  DrawDownPercent = zeros(size(ret));
  DrawDownAbs = zeros(size(ret));
  
  C = ret(1,:);
  
  for i = 2:len
      C = max(ret(i,:),C);
      if C == ret(i)
          DrawDownPercent(i,:) = 0;
          DrawDownAbs(i,:) = 0;
      else
          DrawDownPercent(i,:) = abs(((ret(i,:) - C) ./ C)*100);
          DrawDownAbs(i,:) = (ret(i,:) - C);
      end
  end
  
  
  
  
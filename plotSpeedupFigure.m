%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%   This file is part of SemanticFastForward_ICIP.
%
%    SemanticFastForward_ICIP is free software: you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation, either version 3 of the License, or
%    (at your option) any later version.
%
%    SemanticFastForward_ICIP is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with SemanticFastForward_ICIP.  If not, see <http://www.gnu.org/licenses/>.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function plotSpeedupFigure
    Y= [0.9477,0.9861,0.9710;0.9647,0.9857,0.9776;0.9664,0.9872,0.9726;0.9664,...
        0.9893,0.9731;0.5269,0.9833,0.9000;0.9473,0.9847,1.0000;0.8544,0.9948,...
        0.9636;0.9758,0.9827,0.9564;0.9242,0.9956,0.9694;];
    E = std(Y);
    M = mean(Y);
    a = errorbar(M*100,E*100, 'bs');
    set(a(1), 'LineWidth', 1.5);
    set(a(1), 'MarkerSize', 10);
    set(a(1), 'MarkerEdgeColor', 'r');
    set(a(1), 'MarkerFaceColor', [0,1,0]);
    b = gca;
    b.XTickLabel = {'EgoSampling' 'Microsoft Hyperlapse' 'Ours'};
    b.XTick = [1 2 3];
    b.YTickLabel = {'75%' '80%' '85%' '90%' '95%' '100%' '105%'};
    grid on;
    title('Speed-up Evaluation', 'FontSize', 18);
    set(b, 'FontName','Times New Roman', 'FontSize', 16);
    xlabel('Algorithm','FontName','Times New Roman');
    ylabel('Perfect Speed-up Proximity','FontName','Times New Roman');
    saveas(b, 'speedup.png');
    saveas(b, 'speedup.pdf');
end
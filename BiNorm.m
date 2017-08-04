% %BiNorm.m
% % Plots the Bivariate Normal Density Function for Various Parameters Values
% % author: David Dobor 
% 
% clear all;close all;
% 
% %% Define a Gaussian with a Full Covariance Matrix 
% mu = [1;2];
% sigma = [0.8 0.7;0.7 1.3];
% % Define the grid for visualisation
% [X,Y] = meshgrid(-3:0.07:4,-2:0.07:5);
% % Define the constant
% const = (1/sqrt(2*pi))^2;
% const = const/sqrt(det(sigma));
% % Compute Density at every point on the grid
% temp = [X(:)-mu(1) Y(:)-mu(2)];
% pdf = const*exp(-0.5*diag(temp*inv(sigma)*temp'));
% pdf = reshape(pdf,size(X));
% 
% % plot the result 
% figure(1)
% surfc(X, Y, pdf, 'LineStyle', 'none');
% 
% %add some info to the plot
% mu_str = '$$\mu = \left[ \begin{array} {c} 1 \\  2 \end{array} \right]$$';
% text('Interpreter','latex',...
% 	'String',mu_str,...
% 	'Position',[-2.6 4.2],...
% 	'FontSize',11, 'Color', 'white')
% 
% sigma_str = '$$\Sigma = \left[ \begin{array}{cc} 0.8 & 0.7 \\ 0.7 & 1.3\end{array} \right]$$';
% text('Interpreter','latex',...
% 	'String',sigma_str,...
% 	'Position',[-2.6 3],...
% 	'FontSize', 11, 'Color', 'white')
% 
% % Add title and axis labels
% set(gca,'Title',text('String','Bivariate Normal Density, Full Covariance',...
%                      'FontAngle', 'italic', 'FontWeight', 'bold'),...
%          'xlabel',text('String', '$\mathbf{X}$', 'Interpreter', 'latex'),...
%          'ylabel',text('String', '$\mathbf{Y}$', 'Interpreter', 'latex'))
% 
% % Adjust the view angle
% view(0, 90);
% colormap('hot')
% 
% %plot the surface in 3-d (no need to recompute meshgrid but done anyway)
% figure(2)
% [X,Y] = meshgrid(-3:0.1:4,-2:0.1:5);
% const = (1/sqrt(2*pi))^2;
% const = const/sqrt(det(sigma));
% temp = [X(:)-mu(1) Y(:)-mu(2)];
% pdf = const*exp(-0.5*diag(temp*inv(sigma)*temp'));
% pdf = reshape(pdf,size(X));
% 
% mesh(X, Y, pdf);
% 
% % Add title and axis labels
% set(gca,'Title',text('String','A 3-D View of the Bivariate Normal Density',...
%                      'FontAngle', 'Italic', 'FontWeight', 'bold'),...
%          'xlabel',text('String', '$\mathbf{X}$', 'Interpreter', 'latex'),...
%          'ylabel',text('String', '$\mathbf{Y}$', 'Interpreter', 'latex'),...
%          'zlabel',text('String', 'density', 'FontAngle', 'Italic', 'FontWeight', 'bold'))
% view(-10, 50)
% colormap('winter')
% 
% %% Define Gaussian with the spherical covariance matrix
% mu = [2;2];
% sigma = [0.5 0;0 0.5];
% [X,Y] = meshgrid(0:0.05:4,0:0.05:4);
% % Define the constant
% const = (1/sqrt(2*pi))^2;
% const = const/sqrt(det(sigma));
% % Compute Density at every point on the grid
% temp = [X(:)-mu(1) Y(:)-mu(2)];
% pdf = const*exp(-0.5*diag(temp*inv(sigma)*temp'));
% pdf = reshape(pdf,size(X));
% 
% % plot the result 
% figure(3)
% surfc(X, Y, pdf, 'LineStyle', 'none');
% axis equal
% 
% %add some info to the plot
% mu_str = '$$\mu = \left[ \begin{array} {c} 2 \\  2 \end{array} \right]$$';
% text('Interpreter','latex',...
% 	'String',mu_str,...
% 	'Position',[0.3 3.5],...
% 	'FontSize',11, 'Color', 'white')
% 
% sigma_str = '$$\Sigma = \left[ \begin{array}{cc} 0.5 & 0 \\ 0 & 0.5\end{array} \right]$$';
% text('Interpreter','latex',...
% 	'String',sigma_str,...
% 	'Position',[2.5 3.5],...
% 	'FontSize', 11, 'Color', 'white')
% 
% % Add title and axis labels
% set(gca,'Title',text('String','Bivariate Normal Density, Spherical Covariance',...
%                      'FontAngle', 'italic', 'FontWeight', 'bold'),...
%          'xlabel',text('String', '$\mathbf{X}$', 'Interpreter', 'latex'),...
%          'ylabel',text('String', '$\mathbf{Y}$', 'Interpreter', 'latex'))
% 
% % Adjust the view angle
% view(0, 90);
% colormap('hot')


%% Define Gaussian with the diagonal covariance matrix
mu = [2;2];
sigma = [0.7 0;0 0.25];
width = 1920;
height = 1080;
[X,Y] = meshgrid(0:0.05:width/20,0:0.05:height/20);
% Define the constant
const = (1/sqrt(2*pi))^2;
const = const./sqrt(det(sigma));
% Compute Density at every point on the grid
temp = [X(:)-mu(1) Y(:)-mu(2)];
pdf = const*exp(-0.5*diag(temp*inv(sigma)*temp'));
pdf = reshape(pdf,size(X));

% plot the result 
figure(4)
surfc(X, Y, pdf, 'LineStyle', 'none');
axis equal

%add some info to the plot
mu_str = '$$\mu = \left[ \begin{array} {c} 2 \\  2 \end{array} \right]$$';
text('Interpreter','latex',...
	'String',mu_str,...
	'Position',[0.3 3.5],...
	'FontSize',11, 'Color', 'white')

sigma_str = '$$\Sigma = \left[ \begin{array}{cc} 0.25 & 0 \\ 0 & 0.7\end{array} \right]$$';
text('Interpreter','latex',...
	'String',sigma_str,...
	'Position',[2.5 3.5],...
	'FontSize', 11, 'Color', 'white')

% Add title and axis labels
set(gca,'Title',text('String','Bivariate Normal Density, Diagonal Covariance',...
                     'FontAngle', 'italic', 'FontWeight', 'bold'),...
         'xlabel',text('String', '$\mathbf{X}$', 'Interpreter', 'latex'),...
         'ylabel',text('String', '$\mathbf{Y}$', 'Interpreter', 'latex'))

% Adjust the view angle
view(0, 90);
colormap('hot')
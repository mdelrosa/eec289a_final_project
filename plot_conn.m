function plot_conn(coordinates,connectivity,Xlim,Ylim)

    %disp(connectivity);
    figure(1);
    subplot(1,2,1);
    for i = 1:size(connectivity,1)
        [~,nearest] = max(connectivity(i,:));
        p = [coordinates(i,1), coordinates(i,2); ...
             coordinates(nearest,1), coordinates(nearest,2)];
        plot(p(:,1),p(:,2),'-o');
        hold on;
    end
    hold off;
    xlim([0,Xlim]);
    ylim([0,Ylim]);
    grid on;
    pbaspect([1 1 1]);
    
    subplot(1,2,2);
    scatter(coordinates(:,1),coordinates(:,2));
    ylim([0, Xlim]);
    xlim([0, Ylim]);
    grid on;
    pbaspect([1 1 1]);
    
end


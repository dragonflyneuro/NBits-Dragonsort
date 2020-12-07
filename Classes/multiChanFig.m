classdef multiChanFig < handle
    properties
        f
        panelU
        axesU = gobjects(2,0);
        panelT
        axesT = gobjects(0);
        shownCh = [];
        titles = [];
    end
    
    methods
        function obj = multiChanFig(shownCh,varargin)
            obj.f = uifigure('Position',[50,50,1800,900]);
            g = uigridlayout(obj.f);
            g.RowHeight = repmat({'1x'},[1,2+length(shownCh)]);
            g.ColumnWidth = repmat({'1x'},[1,length(shownCh)]);
            g.ColumnSpacing = 0;
            g.RowSpacing = 0;
            g.Padding = [0 0 0 0];
            
            app.TTitle = uilabel(h);
            app.TTitle.HorizontalAlignment = 'center';
            app.TTitle.FontWeight = 'bold';
            app.TTitle.BackgroundColor = [0.8 0.8 0.8];
            app.TTitle.Layout.Row = jj;
            app.TTitle.Layout.Column = ii;
            app.TTitle.Value = ['Unit',;
            for ii = 1:length(shownCh)
                for jj = 1:2
                    np = uipanel(g);
                    np.BorderType = 'none';
                    np.Layout.Row = jj*2;
                    np.Layout.Column = ii;
                    obj.panelU(jj,ii) = np;
                    obj.axesU(jj,ii) = axes('Parent',obj.panelU(jj,ii));
                end
                np = uipanel(g);
                np.BorderType = 'none';
                np.Layout.Row = 4+ii;
                if length(shownCh) == 1
                    np.Layout.Column = 1;
                else
                    np.Layout.Column = [1, length(shownCh)];
                end
                obj.panelT(ii) = np;
                obj.axesT = axes('Parent',obj.panelT(ii));
            end

        end
    end
end
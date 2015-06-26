function draw( obj, vtype, vrange, thresh )
    % type is either beta or tstat
    if nargin < 2, vtype = 'tstat'; end

    values = obj.(vtype);

    % range to show
    if nargin < 3 || isempty(vrange)
        vmax    = max(abs(values(:)));
        vrange  = vmax*[-1 1];
    end

    % significance mask
    if nargin < 4
        mask = ones(size(values)) > 0;
        
    elseif isscalar(thresh)
        mask = abs(values) > thresh;
        
    elseif isvector(thresh) && isnumeric(thresh)
        mask = values < thresh(1) | values > thresh(2);
        
    elseif isstr(thresh)
        % takes in string in form of 'p < 0.05' or 'q < 0.10'
        s = strtrim( strsplit( thresh, '<' ) );
        
        mask = obj.(s{1}) < str2double(s{2});
    end

    % meas types
    types = obj.probe.link.type;

    % convert to strings for consistency in loop below
    if any(isnumeric(types))
        types = cellfun(@(x) {num2str(x)}, num2cell(types));
    end

    % unique types
    utypes = unique(types, 'stable');
    
    % unique conditions
    uconds = unique(obj.variables.condition, 'stable');
    
    % colormap
    [~,cmap] = evalc('flipud( cbrewer(''div'',''RdBu'',2001) )');
    z = linspace(vrange(1), vrange(2), size(cmap,1))';

    for iCond = 1:length( uconds )
        for iType = 1:length(utypes)
            lst = strcmp( obj.variables.type, utypes(iType) ) & ...
                strcmp( obj.variables.condition, uconds(iCond) );
            
            % values
            vals = values(lst);
            
            % this mask
            m = mask(lst);
            
            % map to colors
            idx = bsxfun(@minus, vals', z);
            [~, idx] = min(abs(idx), [], 1);
            
            colors = cmap(idx, :);
            
            % line styles
            lineStyles = {};
            for i = 1:length(idx)
                if m(i)
                    lineStyles(i,:) = {'LineStyle', '-', 'LineWidth', 8};
                else
                    lineStyles(i,:) = {'LineStyle', '--', 'LineWidth', 4};
                end
            end
            
            figure;
            obj.probe.draw(colors, lineStyles);
            c = colorbar; colormap(cmap); caxis(vrange);
            a = gca;
            
            ap = get(a, 'Position');
            
            cp = get(c, 'Position');
            cp(3) = 0.5*cp(3);
            set(c, 'Position', cp);
            set(a, 'Position', ap);
            
            title([utypes{iType} ' : ' uconds{iCond}], 'Interpreter','none')
        end
    end
end
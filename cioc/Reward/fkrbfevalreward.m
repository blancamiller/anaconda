% Gaussian rbf in end effector space for robot arm tasks.
function [r,g,drdu,d2rdudu,drdx,d2rdxdx,gfull,Hfull] = ...
    fkrbfevalreward(reward,mdp_data,x,u,states,A,B,dxdu,d2xdudu)

% Check if this is a visualization call.
if isempty(x) && size(states,2) == 2,
    % This visualization call is already in Cartesian coordinates.
    d = bsxfun(@minus,reward.pos,states);
    r = reward.r*exp(-0.5*reward.width*sum(d.^2,2));
    if nargout > 1,
        error('Visualization call only supports a single return argument');
    end;
    return;
end;

% Get constants.
T = size(u,1);
Du = size(u,2);
Dx = size(states,2);

% Convert states to Cartesian space.
[ptx,pty,jacx,jacy,jjacx,jjacy] = robotarmfk(states,mdp_data);
pts = [ptx(:,end) pty(:,end)];

% Compute distances.
d = bsxfun(@minus,reward.pos,pts);

% Compute value.
r = reward.r*exp(-0.5*reward.width*sum(d.^2,2));

if nargout >= 2,
    % Compute gradient.
    drdx = [permute(sum(bsxfun(@times,(reward.width*bsxfun(@times,d,r)),[jacx(:,end,:) jacy(:,end,:)]),2),[1 3 2]) zeros(T,Du)];
    g = permute(gradprod(A,B,permute(drdx,[1 3 2])),[1 3 2]);
end;

if nargout >= 3,
    % Gradients with respect to controls are always zero.
    drdu = zeros(T,Du);
    d2rdudu = zeros(T,Du,Du);
end;

if nargout >= 6,
    % drdx has already been computed.
    d2rdxdx = zeros(T,Dx,Dx);
    for t=1:T,
        drdp = reward.width*bsxfun(@times,d(t,:),r(t,:));
        d2rdp2 = (reward.width^2)*bsxfun(@times,d(t,:),d(t,:)')*r(t) - reward.width*r(t)*eye(2);
        J = [permute(jacx(t,end,:),[3 1 2]) permute(jacy(t,end,:),[3 1 2])];
        D = J*d2rdp2*J' + permute(sum(bsxfun(@times,drdp,[jjacx(t,end,:,:) jjacy(t,end,:,:)]),2),[3 4 1 2]);
        d2rdxdx(t,:,:) = [D zeros(Du,Du); zeros(Du,Dx)];
    end;
end;

if nargout >= 7,
    % Compute gfull.
    % Convert gradient to T x TD matrix.
    drdxmat = zeros(T,T*Dx);
    for i=1:Dx,
        drdxmat(:,(i-1)*T + (1:T)) = diag(drdx(:,i));
    end;

    % Compute gradient with respect to controls.
    gfull = drdxmat * dxdu';
    
    % Compute Hfull.
    Hfull = zeros(T,T*Du,T*Du);
    for t=1:T,
        idxs = (0:(Dx-1))*T + t;
        D = permute(d2rdxdx(t,:,:),[2 3 1]);
        Hfull(t,:,:) = dxdu(:,idxs) * D * dxdu(:,idxs)' + sum(bsxfun(@times,permute(drdx(t,:),[1 3 2]),d2xdudu(:,:,idxs)),3);
    end;
end;

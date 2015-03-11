function cname = conv_cspec_to_cname(color)
%for converting between colorspec and named html color
%http://www.mathworks.com/help/techdoc/ref/colorspec.html
cname='';

if ischar(color)
  switch color
    case 'y'
      cname = 'yellow';
    case 'm'
      cname = 'Fuchsia';
    case 'c'
      cname = 'cyan';
    case 'r'
      cname = 'red';
    case 'g'
      cname = 'green';
    case 'b'
      cname = 'blue';
    case 'w'
      cname = 'white';
    case 'k'
      cname = 'black';
  end
else
  col=color*256;
  cname=['rgb(' num2str(col(1)) ',' num2str(col(2)) ',' num2str(col(3)) ')'];
end
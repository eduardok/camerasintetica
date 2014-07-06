unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, OleCtrls, WAITEGLLib_TLB, ComCtrls, ExtCtrls, Opengl, Buttons;

type
  TForm1 = class(TForm)
    Panel1: TPanel;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    tposx: TTrackBar;
    tposy: TTrackBar;
    tposz: TTrackBar;
    janela: TWaiteGL;
    trotz: TTrackBar;
    troty: TTrackBar;
    trotx: TTrackBar;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    lblposx: TLabel;
    lblposy: TLabel;
    lblposz: TLabel;
    lblrotx: TLabel;
    lblroty: TLabel;
    lblrotz: TLabel;
    projecao: TRadioGroup;
    GroupBox3: TGroupBox;
    shademodel: TRadioGroup;
    especmat: TGroupBox;
    tbespec: TTrackBar;
    lblespecmat: TLabel;
    expesp: TGroupBox;
    tbBrilho: TTrackBar;
    lblbrilho: TLabel;
    GroupBox6: TGroupBox;
    chkDifusa: TCheckBox;
    chkEspecular: TCheckBox;
    chkAmbiente: TCheckBox;
    Panel2: TPanel;
    desativada: TCheckBox;
    chkCor: TCheckBox;
    GroupBox4: TGroupBox;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    chkposicao: TCheckBox;
    procedure trotxChange(Sender: TObject);
    procedure tposxChange(Sender: TObject);
    procedure projecaoClick(Sender: TObject);
    procedure janelaSetupRC(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure janelaRender(Sender: TObject);
    procedure tposyChange(Sender: TObject);
    procedure tposzChange(Sender: TObject);
    procedure trotyChange(Sender: TObject);
    procedure trotzChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure desativadaClick(Sender: TObject);
    procedure shademodelClick(Sender: TObject);
    procedure chkCorClick(Sender: TObject);
    procedure tbBrilhoChange(Sender: TObject);
    procedure tbespecChange(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure chkAmbienteClick(Sender: TObject);
    procedure chkposicaoClick(Sender: TObject);
    procedure chkDifusaClick(Sender: TObject);
    procedure chkEspecularClick(Sender: TObject);
  private
    { Private declarations }
    procedure Desenha_Eixos;
    procedure Desenha_Cena;
    procedure Define_Luz;
  public
    { Public declarations }
   rotacaox,rotacaoy,rotacaoz : Integer;
   Poscamerax,Poscameray,Poscameraz : Real;
   Orx,Ory,Orz,Upx,Upy,Upz : Integer;
  end;

var
  Form1: TForm1;
  //Propriedades refletivas do objeto com relacao a luminosidade
  luz_ambiente  : Array[0..3] of GLfloat = (0.2, 0.2, 0.2, 1.0);
  luz_difusa    : Array[0..3] of GLfloat = (0.7, 0.7, 0.7, 1.0); //"cor"
  luz_especular : Array[0..3] of GLfloat = (1.0, 1.0, 1.0, 1.0); //"brilho"
  posicao_luz   : Array[0..3] of GLfloat = (0.0, 25.0,25.0,1.0);
  zera          : Array[0..3] of GLfloat = (0.0, 0.0, 0.0, 1.0);
  //Capacidade de brilho do material
  especularidade: Array[0..3] of GLfloat = (1.0, 1.0, 1.0, 1.0);
  brilho        : GLint = 130;
implementation

{$R *.DFM}

procedure TForm1.trotxChange(Sender: TObject);
begin
   Rotacaox := Trotx.position;
   Trotx.selend := rotacaox;
   Lblrotx.caption := inttostr(Rotacaox);
   Janela.invalidate;
end;

procedure TForm1.tposxChange(Sender: TObject);
begin
   Poscamerax := Tposx.position;
   TPosx.selend := TPosx.position;
   Lblposx.caption := floattostr(poscamerax);
   janela.invalidate;
end;

procedure TForm1.projecaoClick(Sender: TObject);
begin
   janela.invalidate;
end;

procedure TForm1.Desenha_Eixos;
begin
   GLBegin(GL_Lines);
      GLcolor3f(1.0,0.0,0.0);
      GLvertex3f(0.0,0.0,0.0);
      GLvertex3f(2.0,0.0,0.0);
      GLcolor3f(0.0,1.0,0.0);
      GLvertex3f(0.0,0.0,0.0);
      GLvertex3f(0.0,2.0,0.0);
      GLcolor3f(0.0,0.0,1.0);
      GLvertex3f(0.0,0.0,0.0);
      GLvertex3f(0.0,0.0,2.0);
   GLend;
end;

procedure TForm1.janelaSetupRC(Sender: TObject);
begin
   GLclearcolor(0.0,0.0,0.0,1.0);
   GLflush;
   Define_Luz;
end;

procedure TForm1.FormActivate(Sender: TObject);
begin
   janela.MakeCurrent;
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
   janela.MakeNotCurrent;
end;

procedure TForm1.janelaRender(Sender: TObject);
begin
   //Se nao limpar tb o DEPTH_BUFFER_BIT, nao usa DEPTH_BUFFER_TEST
   GLclear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
   GLmatrixmode(GL_Projection);
   GLloadidentity;
   if(Projecao.itemindex=0) then begin
      GLortho(-2.0,2.0,-2.0,2.0,-10.0,10.0);
      end
   else begin
      GLuperspective(45.0,width/height,0.01,15.0);
   end;
   //Especifica que a cor de fundo da janela será preto
   //            R    G    B    Alpha
   glClearColor(0.0, 0.0, 0.0, 1.0);

   GLulookat(Poscamerax,Poscameray,Poscameraz,Orx,Ory,Orz,Upx,Upy,Upz);
   GLrotatef(Rotacaox,1.0,0.0,0.0);
   GLrotatef(Rotacaoy,0.0,1.0,0.0);
   GLrotatef(Rotacaoz,0.0,0.0,1.0);
   GLmatrixmode(GL_MODELVIEW);
   GLloadidentity;
   Desenha_Eixos;
   Desenha_Cena;
   GLFlush;
   janela.swapbuffers;

end;

procedure TForm1.Desenha_Cena;
begin
   GLcolor3f(0.5,0.5,0.5);
   GLbegin(GL_LINE_LOOP);
      GLvertex3d(-3.0,-3.0,-3.0);
      GLvertex3d(-3.0,-3.0,3.0);
      GLvertex3d(3.0,-3.0,3.0);
      GLvertex3d(3.0,-3.0,-3.0);
   GLend;
   glColor3f(0.0, 0.0, 1.0);  //azul
   janela.auxsolidteapot(0.5);
   GLcolor3f(1.0,0.0,0.5); //rosa 
   GLtranslatef(-2.0,0.0,2.0);
   janela.auxsolidcube(0.5);

   //Cilindro rosa
   GLcolor3f(1.0,0.0,1.0);
   GLtranslatef(4.0,0.0,-3.0);
   //                     raio,altura
   janela.auxsolidcylinder(0.5,0.7);

   //Cilindro ciano
   GLcolor3f(1.0,1.0,1.9);
   GLtranslatef(-2.0,-2.0,0.0);
   janela.auxsolidcylinder(0.3,0.5);

   GLcolor3f(0.0,1.0,0.0); //Verde
   GLtranslatef(2.0,0.0,3.0);
   janela.auxsolidsphere(0.5);

end;

procedure TForm1.tposyChange(Sender: TObject);
begin
   Poscameray := Tposy.position;
   TPosy.selend := TPosy.position;
   Lblposy.caption := floattostr(poscameray);
   janela.invalidate;
end;

procedure TForm1.tposzChange(Sender: TObject);
begin
   Poscameraz := Tposz.position;
   TPosz.selend := TPosz.position;
   Lblposz.caption := floattostr(poscameraz);
   janela.invalidate;
end;

procedure TForm1.trotyChange(Sender: TObject);
begin
   Rotacaoy := Troty.position;
   Troty.selend := rotacaoy;
   Lblroty.caption := inttostr(Rotacaoy);
   Janela.invalidate;
end;

procedure TForm1.trotzChange(Sender: TObject);
begin
   Rotacaoz := Trotz.position;
   Trotz.selend := rotacaoz;
   Lblrotz.caption := inttostr(Rotacaoz);
   Janela.invalidate;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
   rotacaox:=0;   rotacaoy:=0;   rotacaoz:=0;
   poscamerax:=3; poscameray:=3; poscameraz:=3;
   Tposx.position := round(poscamerax);
   Tposx.selend   := Tposx.position;
   Tposy.position := round(poscameray);
   Tposy.selend   := Tposy.position;
   Tposz.position := round(poscameraz);
   Tposz.selend   := Tposz.position;
   lblposx.caption:= floattostr(poscamerax);
   lblposy.caption:= floattostr(poscameray);
   lblposz.caption:= floattostr(poscameraz);
   orx:=0; ory:=0; orz:=0;
   upx:=0; upy:=1; upz:=0;
end;

procedure TForm1.Define_Luz;
begin
   //Habilita o modelo de colorização de Gouraud
   if shademodel.ItemIndex = 1 then begin
      glShadeModel(GL_SMOOTH);
      end
   else glShadeModel(GL_FLAT);

   //Define a refletância do material
   glMaterialfv(GL_FRONT,GL_SPECULAR, @especularidade);
   //Define a concentração do brilho
   glMateriali(GL_FRONT,GL_SHININESS,brilho);

   //Ativa o uso da luz ambiente
   glLightModelfv(GL_LIGHT_MODEL_AMBIENT, @luz_ambiente);

   //Define os parâmetros da luz de número 0
   if chkAmbiente.Checked then begin
      glLightfv(GL_LIGHT0, GL_AMBIENT , @luz_ambiente);
      end
   else glLightfv(GL_LIGHT0, GL_AMBIENT , @zera);

   if chkDifusa.Checked then begin
      glLightfv(GL_LIGHT0, GL_DIFFUSE , @luz_difusa );
      end
   else glLightfv(GL_LIGHT0, GL_DIFFUSE , @zera );

   if chkEspecular.Checked then begin
      glLightfv(GL_LIGHT0, GL_SPECULAR, @luz_especular );
      end
   else glLightfv(GL_LIGHT0, GL_SPECULAR, @zera );

   if chkPosicao.checked then begin
      glLightfv(GL_LIGHT0, GL_POSITION, @posicao_luz );
      end
   else glLightfv(GL_LIGHT0, GL_POSITION, @zera );

   //Habilita a definição da cor do material a partir da cor corrente
   glColorMaterial(GL_FRONT_AND_BACK,GL_AMBIENT_AND_DIFFUSE);
   if chkCor.Checked then begin
      glEnable(GL_COLOR_MATERIAL);
      end
   else glDisable(GL_COLOR_MATERIAL);

   if not desativada.Checked then begin
     //Habilita o uso de iluminação
     glEnable(GL_LIGHTING);
     //Habilita a luz de número 0
     glEnable(GL_LIGHT0);
     end
   else begin //senao
     //Desabilita
     glDisable(GL_LIGHTING);
     glDisable(GL_LIGHT0);
   end;

   //Calcula normais para teapot funcionar
   glEnable(GL_AUTO_NORMAL);
   //Normaliza
   glEnable(GL_NORMALIZE);

   //Habilita o depth-buffering
   glEnable(GL_DEPTH_TEST);
end;

procedure TForm1.desativadaClick(Sender: TObject);
begin
   chkambiente.Enabled  := not desativada.Checked;
   chkespecular.Enabled := not desativada.Checked;
   chkdifusa.Enabled    := not desativada.Checked;
   chkposicao.Enabled   := not desativada.Checked;
   chkCor.Enabled       := not desativada.Checked;
   shademodel.Enabled   := not desativada.Checked;
   especmat.Enabled     := not desativada.Checked;
   expesp.Enabled       := not desativada.Checked;
   Define_Luz;
   Janela.invalidate;
end;

procedure TForm1.shademodelClick(Sender: TObject);
begin
   Define_Luz;
   Janela.invalidate;
end;

procedure TForm1.chkCorClick(Sender: TObject);
begin
   Define_Luz;
   Janela.invalidate;
end;

procedure TForm1.tbBrilhoChange(Sender: TObject);
begin
   lblbrilho.Caption := IntToStr(tbbrilho.position);
   brilho := tbBrilho.Position;
   Define_Luz;
   Janela.invalidate;
end;

procedure TForm1.tbespecChange(Sender: TObject);
begin
   lblespecmat.Caption := IntToStr(tbespec.position);
   especularidade[0] := tbespec.Position;
   especularidade[1] := tbespec.Position;
   especularidade[2] := tbespec.Position;
   Define_Luz;
   Janela.invalidate;
end;

procedure TForm1.SpeedButton1Click(Sender: TObject);
begin
   close();
end;

procedure TForm1.chkAmbienteClick(Sender: TObject);
begin
   Define_Luz;
   Janela.invalidate;
end;

procedure TForm1.chkposicaoClick(Sender: TObject);
begin
   Define_Luz;
   Janela.invalidate;
end;

procedure TForm1.chkDifusaClick(Sender: TObject);
begin
   Define_Luz;
   Janela.invalidate;
end;

procedure TForm1.chkEspecularClick(Sender: TObject);
begin
   Define_Luz;
   Janela.invalidate;
end;

end.


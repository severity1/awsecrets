require 'spec_helper'

describe Awsecrets do
  let(:fixtures_path) do
    File.expand_path(File.join(File.dirname(__FILE__), 'fixtures'))
  end

  before(:each) do
    stub_const('ENV', {})
    AWSConfig.config_file = File.expand_path(File.join(fixtures_path, '.aws', 'config'))
    allow(Dir).to receive(:home).and_return(fixtures_path)
  end

  it 'has a version number' do
    expect(Awsecrets::VERSION).not_to be nil
  end

  context 'Configration' do
    it 'load --profile option' do
      Awsecrets.load(profile: 'dev')
      expect(Aws.config[:region]).to eq('CONFIG_DEFAULT_REGION')
      expect(Aws.config[:credentials].credentials.access_key_id).to eq('CREDS_DEV_ACCESS_KEY_ID')
      expect(Aws.config[:credentials].credentials.secret_access_key).to eq('CREDS_DEV_SECRET_ACCESS_KEY')
    end

    it 'load --region option' do
      Awsecrets.load(region: 'OPTION_REGION')
      expect(Aws.config[:region]).to eq('OPTION_REGION')
      expect(Aws.config[:credentials].credentials.access_key_id).to eq('CREDS_DEFAULT_ACCESS_KEY_ID')
      expect(Aws.config[:credentials].credentials.secret_access_key).to eq('CREDS_DEFAULT_SECRET_ACCESS_KEY')
    end

    it 'load secrets.yml' do
      Awsecrets.load(secrets_path: File.expand_path(File.join(fixtures_path, 'secrets.yml')))
      expect(Aws.config[:region]).to eq('YAML_REGION')
      expect(Aws.config[:credentials].credentials.access_key_id).to eq('YAML_ACCESS_KEY_ID')
      expect(Aws.config[:credentials].credentials.secret_access_key).to eq('YAML_SECRET_ACCESS_KEY')
    end

    it 'load AWS_PROIFLE' do
      stub_const('ENV', { 'AWS_PROFILE' => 'dev' })
      Awsecrets.load
      expect(Aws.config[:region]).to eq('CONFIG_DEFAULT_REGION')
      expect(Aws.config[:credentials].credentials.access_key_id).to eq('CREDS_DEV_ACCESS_KEY_ID')
      expect(Aws.config[:credentials].credentials.secret_access_key).to eq('CREDS_DEV_SECRET_ACCESS_KEY')
    end

    it 'load AWS_DEFAULT_PROIFLE' do
      stub_const('ENV', { 'AWS_DEFAULT_PROFILE' => 'default' })
      Awsecrets.load
      expect(Aws.config[:region]).to eq('CONFIG_DEFAULT_REGION')
      expect(Aws.config[:credentials].credentials.access_key_id).to eq('CREDS_DEFAULT_ACCESS_KEY_ID')
      expect(Aws.config[:credentials].credentials.secret_access_key).to eq('CREDS_DEFAULT_SECRET_ACCESS_KEY')
    end

    it 'load AWS_REGION' do
      stub_const('ENV', { 'AWS_REGION' => 'ENV_REGION' })
      Awsecrets.load
      expect(Aws.config[:region]).to eq('ENV_REGION')
      expect(Aws.config[:credentials].credentials.access_key_id).to eq('CREDS_DEFAULT_ACCESS_KEY_ID')
      expect(Aws.config[:credentials].credentials.secret_access_key).to eq('CREDS_DEFAULT_SECRET_ACCESS_KEY')
    end

    it 'load AWS_DEFAULT_REGION' do
      stub_const('ENV', { 'AWS_DEFAULT_REGION' => 'ENV_DEFAULT_REGION' })
      Awsecrets.load
      expect(Aws.config[:region]).to eq('ENV_DEFAULT_REGION')
      expect(Aws.config[:credentials].credentials.access_key_id).to eq('CREDS_DEFAULT_ACCESS_KEY_ID')
      expect(Aws.config[:credentials].credentials.secret_access_key).to eq('CREDS_DEFAULT_SECRET_ACCESS_KEY')
    end

    it 'load AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY' do
      stub_const('ENV', {
                   'AWS_ACCESS_KEY_ID' => 'ENV_ACCESS_KEY_ID',
                   'AWS_SECRET_ACCESS_KEY' => 'ENV_SECRET_ACCESS_KEY'
                 })
      Awsecrets.load
      expect(Aws.config[:region]).to eq('CONFIG_DEFAULT_REGION')
      expect(Aws.config[:credentials].credentials.access_key_id).to eq('ENV_ACCESS_KEY_ID')
      expect(Aws.config[:credentials].credentials.secret_access_key).to eq('ENV_SECRET_ACCESS_KEY')
      expect(Aws.config[:credentials].credentials.session_token).to be_nil
    end

    it 'load AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_SESSION_TOKEN' do
      stub_const('ENV', {
                   'AWS_ACCESS_KEY_ID' => 'ENV_ACCESS_KEY_ID',
                   'AWS_SECRET_ACCESS_KEY' => 'ENV_SECRET_ACCESS_KEY',
                   'AWS_SESSION_TOKEN' => 'ENV_SESSION_TOKEN'
                 })
      Awsecrets.load
      expect(Aws.config[:region]).to eq('CONFIG_DEFAULT_REGION')
      expect(Aws.config[:credentials].credentials.access_key_id).to eq('ENV_ACCESS_KEY_ID')
      expect(Aws.config[:credentials].credentials.secret_access_key).to eq('ENV_SECRET_ACCESS_KEY')
      expect(Aws.config[:credentials].credentials.session_token).to eq('ENV_SESSION_TOKEN')
    end
  end

  context 'Precedence' do
    it '--profile option > AWS_PROFILE' do
      stub_const('ENV', { 'AWS_PROFILE' => 'production' })
      Awsecrets.load(profile: 'dev')
      expect(Aws.config[:region]).to eq('CONFIG_DEFAULT_REGION')
      expect(Aws.config[:credentials].credentials.access_key_id).to eq('CREDS_DEV_ACCESS_KEY_ID')
      expect(Aws.config[:credentials].credentials.secret_access_key).to eq('CREDS_DEV_SECRET_ACCESS_KEY')
    end

    it '--profile option > AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY' do
      stub_const('ENV', {
                   'AWS_ACCESS_KEY_ID' => 'ENV_ACCESS_KEY_ID',
                   'AWS_SECRET_ACCESS_KEY' => 'ENV_SECRET_ACCESS_KEY'
                 })
      Awsecrets.load(profile: 'dev')
      expect(Aws.config[:region]).to eq('CONFIG_DEFAULT_REGION')
      expect(Aws.config[:credentials].credentials.access_key_id).to eq('CREDS_DEV_ACCESS_KEY_ID')
      expect(Aws.config[:credentials].credentials.secret_access_key).to eq('CREDS_DEV_SECRET_ACCESS_KEY')
    end

    it '--profile option > secrets.yml (No .aws/config)' do
      Awsecrets.load(profile: 'dev', secrets_path: File.expand_path(File.join(fixtures_path, 'secrets.yml')))
      expect(Aws.config[:region]).to eq('YAML_REGION') # !!!
      expect(Aws.config[:credentials].credentials.access_key_id).to eq('CREDS_DEV_ACCESS_KEY_ID')
      expect(Aws.config[:credentials].credentials.secret_access_key).to eq('CREDS_DEV_SECRET_ACCESS_KEY')
    end

    it '--profile option > secrets.yml' do
      Awsecrets.load(profile: 'production', secrets_path: File.expand_path(File.join(fixtures_path, 'secrets.yml')))
      expect(Aws.config[:region]).to eq('CONFIG_PRODUCTION_REGION') # !!!
      expect(Aws.config[:credentials].credentials.access_key_id).to eq('CREDS_PRODUCTION_ACCESS_KEY_ID')
      expect(Aws.config[:credentials].credentials.secret_access_key).to eq('CREDS_PRODUCTION_SECRET_ACCESS_KEY')
    end

    it '--region option > AWS_REGION' do
      stub_const('ENV', { 'AWS_REGION' => 'ENV_REGION' })
      Awsecrets.load(region: 'OPTION_REGION')
      expect(Aws.config[:region]).to eq('OPTION_REGION')
      expect(Aws.config[:credentials].credentials.access_key_id).to eq('CREDS_DEFAULT_ACCESS_KEY_ID')
      expect(Aws.config[:credentials].credentials.secret_access_key).to eq('CREDS_DEFAULT_SECRET_ACCESS_KEY')
    end

    it 'AWS_REGION > AWS_DEFAULT_REGION' do
      stub_const('ENV', {
                   'AWS_REGION' => 'ENV_REGION',
                   'AWS_DEFAULT_REGION' => 'ENV_DEFAULT_REGION'
                 })
      Awsecrets.load
      expect(Aws.config[:region]).to eq('ENV_REGION')
      expect(Aws.config[:credentials].credentials.access_key_id).to eq('CREDS_DEFAULT_ACCESS_KEY_ID')
      expect(Aws.config[:credentials].credentials.secret_access_key).to eq('CREDS_DEFAULT_SECRET_ACCESS_KEY')
    end
  end
end
